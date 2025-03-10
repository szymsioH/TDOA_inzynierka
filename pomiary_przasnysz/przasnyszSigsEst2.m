clear all;
close all;

tic

fs = double(10e+6);
c = 299792458;

files2 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary_przasnysz\sygnały\L2\*.usf');
files3 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary_przasnysz\sygnały\L3\*.usf');
files4 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary_przasnysz\sygnały\L4\*.usf');


folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo';
cd(folder);

[x_car, x_geo] = receiversPositionFunction();

wgs84 = wgs84Ellipsoid("meter");

[x_cassino, y_cassino, z_cassino] = geodetic2enu(52.87536433653608, 20.57999572552401, 96, 53.01735, 20.90708, 0, wgs84);
x_cassino = [x_cassino, y_cassino, z_cassino].';

R_cassino = [norm(x_cassino(1:2, :)-x_car(1:2, 3)), norm(x_cassino(1:2, :)-x_car(1:2, 4)), norm(x_cassino(1:2, :)-x_car(1:2, 5))]; 
    
Real_TOAs = R_cassino/c;

Real_TDOAs = [-Real_TOAs(1)+Real_TOAs(2), -Real_TOAs(1)+Real_TOAs(3)];

folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary';
cd(folder);

all_TDOAs = zeros(6, 2);

errs_TDOAs = zeros(6, 2);

co_value = 5;

%----------------WERYFIKACJA-BLEDOW-ESTYMATY-TDOA-------------------

% fragment_all_TDOAs = zeros(numel(1:2e4:1e7), 2);
% range_b = 1:2e4:1e7;
% 
% for b = 1:2e4:1e7
%     [header2, data2_before] = USF.readUSFFile([files2(2).folder filesep files2(2).name]);
%     [header3, data3_before] = USF.readUSFFile([files3(2).folder filesep files3(2).name]);
%     [header4, data4_before] = USF.readUSFFile([files4(2).folder filesep files4(2).name]);
%     
%     data2 = double(data2_before(b:b+2e4-1));
%     data3 = double(data3_before(b:b+2e4-1));
%     data4 = double(data4_before(b:b+2e4-1));
% 
%     [x23, d23] = (xcorr(data2, data3, 'normalized'));
%     [x24, d24] = (xcorr(data2, data4, 'normalized'));
%     
% 
%     rangecorr = min(d23):(1/co_value):max(d23);
%     corrval23 = interp1(d23, x23, rangecorr, 'spline');
%     max_d23 = -rangecorr(corrval23 == max(corrval23));
%     
%     rangecorr = min(d24):(1/co_value):max(d24);
%     corrval24 = interp1(d24, x24, rangecorr, 'spline');
%     max_d24 = -rangecorr(corrval24 == max(corrval24));
%     
%     max_d23 = -d23(x23 == max(x23))/1;
%     max_d24 = -d24(x24 == max(x24))/1;
% 
%     fragment_all_TDOAs(find(range_b==b), 1) = max_d23/fs;
%     fragment_all_TDOAs(find(range_b==b), 2) = max_d24/fs;
% end
% 
% figure
% stem(range_b, fragment_all_TDOAs(:, 1), 'blue')
% hold on
% stem(range_b, fragment_all_TDOAs(:, 2), 'red')

%----------------------------------------------------------------

for k = 1:6
    k %k to numer pomiaru
    [header2, data2_before] = USF.readUSFFile([files2(k).folder filesep files2(k).name]);
    [header3, data3_before] = USF.readUSFFile([files3(k).folder filesep files3(k).name]);
    [header4, data4_before] = USF.readUSFFile([files4(k).folder filesep files4(k).name]);


    data2_before = double(data2_before(1:250001));
    data3_before = double(data3_before(1:250001));
    data4_before = double(data4_before(1:250001));
    %------------------
    os_value = 1;
    co_value = 1;
    data2 = resample(data2_before, os_value, 1);
    data3 = resample(data3_before, os_value, 1);
    data4 = resample(data4_before, os_value, 1);
    %------------------
    
    [x23, d23] = (xcorr(data2, data3, 'normalized'));
    [x24, d24] = (xcorr(data2, data4, 'normalized'));
    

    rangecorr = min(d23):(1/co_value):max(d23);
    corrval23 = interp1(d23, x23, rangecorr, 'spline');
    max_d23 = -rangecorr(corrval23 == max(corrval23));
    
    rangecorr = min(d24):(1/co_value):max(d24);
    corrval24 = interp1(d24, x24, rangecorr, 'spline');
    max_d24 = -rangecorr(corrval24 == max(corrval24));
    
    max_d23 = -d23(x23 == max(x23))/os_value;
    max_d24 = -d24(x24 == max(x24))/os_value;
    
    TDOA23 = max_d23/fs;
    TDOA24 = max_d24/fs;
    
    all_TDOAs(k, :) = [TDOA23, TDOA24];

    errs_TDOAs(k, :) = Real_TDOAs - all_TDOAs(k, :);

end

Real_TDOAs
all_TDOAs

%correct = mean(errs_TDOAs(1:6, :))
correct = 0

corrected_TDOAs = all_TDOAs + correct

folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo';
cd(folder);
all_errors = zeros(1, 6);
for m = 1:6
    TDOAs = corrected_TDOAs(m, :);
    [x_hat_opt1, ~] = getXhat(TDOAs, x_car, c, 10);
    all_errors(m) = sqrt((x_hat_opt1(1)-x_cassino(1))^2 + (x_hat_opt1(2)-x_cassino(2))^2);
end

TDOAs = corrected_TDOAs(2, :);


all_errors
% %------------------------
% 
%     delays = [max_d23/fs, max_d24/fs];
%     
%     
% 
%     
% 
% 
% %------------------------

[x_hat_opt, fval] = getXhat(TDOAs, x_car, c, 10);


surf_x_range = -30000:100:5000;
surf_y_range = -30000:100:5000;

[X_testpoints, Y_testpoints] = meshgrid(surf_x_range, surf_y_range);
Z_testpoints = zeros(size(X_testpoints));

for i = 1:numel(X_testpoints)
    x_hat = [X_testpoints(i); Y_testpoints(i)];
    Z_testpoints(i) = costFunctionLS_TDOA(x_hat, x_car, TDOAs, c);
end

[minZ, minIdx] = min(Z_testpoints(:));
[minX, minY] = ind2sub(size(Z_testpoints), minIdx);
x_optimal = X_testpoints(minX, minY);
y_optimal = Y_testpoints(minX, minY);
%ABABA ABABAb
figure('Name', 'Cost Function Values Mesh'); 
surf(X_testpoints/1000, Y_testpoints/1000, Z_testpoints);
xlabel('East [km]');
ylabel('North [km]');
title('Cost function value distribution');
hold on
p1 = plot3(x_hat_opt(1)/1000, x_hat_opt(2)/1000, fval+100000, 'c.', 'MarkerSize', 25);
hold on
p2 = plot3(x_car(1, 3:5)/1000, x_car(2, 3:5)/1000, [max(max(Z_testpoints)) max(max(Z_testpoints)) max(max(Z_testpoints))], '^k', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');
p3 = plot3(x_cassino(1)/1000, x_cassino(2)/1000, max(max(Z_testpoints)), 'r.', 'MarkerSize', 20);
p4 = plot3(x_optimal/1000, y_optimal/1000, minZ+100000, 'g.', 'MarkerSize', 25);
legend([p2, p1, p3, p4], { 'Receivers', 'Est. Localization', 'Real Localization', 'Cost function minimum'})
colorbar;
shading interp;
hold on;

% figure
% plot(x_car(1, 3:5), x_car(2, 3:5), '^k', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');
% xlabel('East [m]');
% ylabel('North [m]');
% title('Estymata lokalizacji stacji nadawczej');
% grid on;
% hold on
% plot(x_hat_opt(1), x_hat_opt(2), 'c.', 'MarkerSize', 25)
% hold on
% plot(x_cassino(1), x_cassino(2), 'r.', 'MarkerSize', 20)
% % plot3(x_hat_opt(1), x_hat_opt(2), 120,'g.', 'MarkerSize', 20)
% legend('Odbiorniki', 'Estymowana lokalizacja nadajnika', 'Rzeczywista lokalizacja nadajnika', 'Location', 'best');
% xlim([-4000 4000])
% ylim([-4000 4000])

% disp(x_hat_opt)
% disp('estymowane współżędne: ')
% [lon, lat, h] = enu2geodetic(x_hat_opt(1), x_hat_opt(2), 50, 53.01735, 20.90708, 0, wgs84);
% disp([lon, lat, h])

error = sqrt((x_hat_opt(1)-x_cassino(1))^2 + (x_hat_opt(2)-x_cassino(2))^2)


toc
