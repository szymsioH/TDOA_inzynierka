clear all;
close all;

tic

%Wczytanie lokalizacji odbiorników
[x_car, x_geo] = receiversPositionFunction();

%ustawienia fminunc
x0 = [0; 0];
options = optimoptions('fminunc','Algorithm','quasi-newton','Display','off');

%Prędkość propagacji sygnału
c = 299792458;


xsources = -6000:50:6000;
ysources = -6000:50:6000;


% dev_mesh = zeros(numel(ysources), numel(xsources));
% mean_mesh = zeros(numel(ysources), numel(xsources));
% rms_mesh = zeros(numel(ysources), numel(xsources));

% x0 = [-3000, 3000; 
%     0, 3000;
%     3000, 3000;
%     -3000, 0;
%     0, 0;
%     3000, 0;
%     -3000, -3000;
%     0, -3000;
%     3000, -3000] + 100*randn(9, 2);

% x0_alt = [0, 0];
% [x_hat_opt2, fval2] = fminunc(@(x_hat) costFunctionLS_TDOA(x_hat, x_car, TDOAs, c), x0_alt, options);

% x_index = 0;
% for x = xsources
%     y_index = numel(ysources) + 1;
%     x_index = x_index + 1;
%     for y = ysources
%         y_index = y_index - 1;
%         x_tested = [x, y]
%         fvals(y_index, x_index) = costFunctionLS_TDOA(x_tested, x_car, TDOAs, c);
%     end
% end

% [minValue, linearIdx] = min(fvals(:));
% [min_row, min_col] = ind2sub(size(fvals), linearIdx);


% for x = xsources
%     x
%     for y = ysources
% 
%         R = [norm(x_car(1:2, 3).'-[x, y]);
%                 norm(x_car(1:2, 4).'-[x, y]);
%                 norm(x_car(1:2, 5).'-[x, y])];
% 
%         TOAs = R/c;
%         
%         est_errors = zeros(1, iter_m);
%         for i = 1:iter_m
%             %TDOAs: 1 - s-w, 2 - s-i
% 
%             TDOAs = [-TOAs(1)+TOAs(2); -TOAs(1)+TOAs(3)];
% 
%             [x_hat_opt, fval] = fminunc(@(x_hat) costFunctionLS_TDOA(x_hat, x_car, TDOAs, c), x0, options);
% 
% %             x_hat_opt2 = zeros(2, size(x0,1));
% %             fval = zeros(1, size(x0, 1));
% %             for k = 1:size(x0,1)
% %                 [x_hat_opt2(:, k), fval(k)] = fminunc(@(x_hat) costFunctionLS_TDOA(x_hat, x_car, TDOAs, c), x0(k, :), options);
% %             end
% %             [~,index] = min(fval);
% % 
% %             x_hat_opt = x_hat_opt2(:, index);
%             est_errors(i) = norm(x_hat_opt - [x; y]);
%         end
%         dev_mesh(ysources==y, xsources==x) = std(est_errors);
%         mean_mesh(ysources==y, xsources==x) = mean(est_errors);
%         rms_mesh(ysources==y, xsources==x) = rms(est_errors);
%     end
% end
    
x_test = [-3200, -2000];

R = [norm(x_car(1:2, 3).'-[x_test(1), x_test(2)]);
                norm(x_car(1:2, 4).'-[x_test(1), x_test(2)]);
                norm(x_car(1:2, 5).'-[x_test(1), x_test(2)])];
TOAs = R/c;
TDOAs = [-TOAs(1)+TOAs(2); -TOAs(1)+TOAs(3)];


[X_testpoints, Y_testpoints] = meshgrid(xsources, ysources);
Z_testpoints = zeros(size(X_testpoints));


for k = 1:numel(X_testpoints)
    x_hat2 = [X_testpoints(k); Y_testpoints(k)];
    Z_testpoints(k) = costFunctionLS_TDOA(x_hat2, x_car, TDOAs, c);
end

clear k
% clear options

[minZ, minIdx] = min(Z_testpoints(:));
[minX, minY] = ind2sub(size(Z_testpoints), minIdx);
x_optimal = X_testpoints(minX, minY);
y_optimal = Y_testpoints(minX, minY);

x0 = [0; 0];

if size(x0) ~= [2,1]
    disp('ŹLE WPISANY X0!!!!!  (x0 = [x; y])')
end

[x_hat_opt0, fval0] = fminunc(@(x_hat) costFunctionLS_TDOA(x_hat, x_car, TDOAs, c), x0, options);
x_hat_opt0

R_control = [norm(x_car(1:2, 3)-x_hat_opt0), norm(x_car(1:2, 4)-x_hat_opt0), norm(x_car(1:2, 5)-x_hat_opt0)];

[r_min, nearest_sensor_index] = min(R_control);

nearest_sensor_index = nearest_sensor_index + 2;

% R_difference = x_hat_opt0 - x_car(1:2, nearest_sensor_index);
R_difference = x_hat_opt0 - [0;0];

x0 = x_hat_opt0 + 1*R_difference;

[x_hat_opt1, fval1] = fminunc(@(x_hat) costFunctionLS_TDOA(x_hat, x_car, TDOAs, c), x0, options);

if fval0 < fval1
    x_hat_opt = x_hat_opt0;
elseif fval0 > fval1
    x_hat_opt = x_hat_opt1;
elseif fval0 == fval1
    x_hat_opt = x_hat_opt0;
end



figure('Name', 'Cost Function Values Mesh'); 
surf(X_testpoints, Y_testpoints, Z_testpoints);
xlabel('East [m]');
ylabel('North [m]');
title('Rozkład wartości funkcji kosztu');
hold on
%plot3(x_optimal, y_optimal, Z_testpoints(minIdx), 'g.', 'MarkerSize', 20)
p1 = plot3(x_optimal, y_optimal, minZ, 'r.', 'MarkerSize', 35);
p2 = plot3(x_test(1), x_test(2), max(max(Z_testpoints)), 'k.', 'MarkerSize', 15, 'MarkerFaceColor', 'green');
p5 = plot3(x0(1), x0(2), max(max(Z_testpoints)), 'y.', 'MarkerSize', 20);
% p3 = plot3(x_hat_opt0(1), x_hat_opt0(2), fval0, 'c.', 'MarkerSize', 25);
p3 = plot3(x_hat_opt1(1), x_hat_opt1(2), fval1, 'c.', 'MarkerSize', 25);
% plot3(x_hat_opt2(1), x_hat_opt2(2), fval2, 'c.', 'MarkerSize', 25)
p4 = plot3(x_car(1, 3:5), x_car(2, 3:5), [max(max(Z_testpoints)) max(max(Z_testpoints)) max(max(Z_testpoints))], '^k', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');
%plot3(x/1000, y/1000, max(max(Z_testpoints)), 'g.', 'MarkerSize', 20)
colorbar;
shading interp;
legend([p1, p2, p5, p3, p4], {'Najmniejsza wartość funkcji kosztu', 'Prawdziwa lok. nadajnika', 'Nowy punkt początkowy', 'Estymowana lok. nadajnika', 'Odbiorniki'})
    
%     figure('Name', 'Standard Deviation');
%     clim2 = [0 4000];
%     imagesc(xsources, ysources, dev_mesh, clim2)
%     colorbar;
%     xlabel('x [m]')
%     ylabel('y [m]')
%     axis xy
%     title('Odchylenie Standardowe [m] względem położenia nadajnika')
%     hold on
%     plot(x_car(1, 3:5).', x_car(2, 3:5).', '^k', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');
    
%     figure('Name', 'Root Mean Squere');
%     clim3 = [0 4000];
%     imagesc(xsources, ysources, rms_mesh, clim3)
%     colorbar;
%     xlabel('x [m]')
%     ylabel('y [m]')
%     axis xy
%     title('Błąd Średniokwadratowy [m]')
%     hold on
%     plot(x_car(1, 3:5).', x_car(2, 3:5).', '^k', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');

% end

toc