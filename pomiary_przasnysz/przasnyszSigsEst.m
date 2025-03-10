clear all;
% close all;

fs = double(10e+6);
c = 299792458;

files2 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary_przasnysz\sygnały\L2\*.usf');
files3 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary_przasnysz\sygnały\L3\*.usf');
files4 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary_przasnysz\sygnały\L4\*.usf');

folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary';
cd(folder);

[header2, data2] = USF.readUSFFile([files2(3).folder filesep files2(3).name]);
[header3, data3] = USF.readUSFFile([files3(3).folder filesep files3(3).name]);
[header4, data4] = USF.readUSFFile([files4(3).folder filesep files4(3).name]);


data2 = double(data2);
data3 = double(data3);
data4 = double(data4);

%------------------
% os_value = 5;
% co_value = 5;
% data2 = resample(data2, os_value, 1);
% data3 = resample(data3, os_value, 1);
% data4 = resample(data4, os_value, 1);
%------------------

[x23, d23] = (xcorr(data2, data3, 'normalized'));
[x24, d24] = (xcorr(data2, data4, 'normalized'));

% rangecorr = min(d23):(1/co_value):max(d23);
% corrval23 = interp1(d23, x23, rangecorr, 'spline');
% max_d23 = -rangecorr(corrval23 == max(corrval23))/os_value;

% rangecorr = min(d24):(1/co_value):max(d24);
% corrval24 = interp1(d24, x24, rangecorr, 'spline');
% max_d24 = -rangecorr(corrval24 == max(corrval24))/os_value;

max_d23 = -d23(x23 == max(x23));
max_d24 = -d24(x24 == max(x24));

TDOA23 = max_d23/fs;
TDOA24 = max_d24/fs;

TDOAs = 1.0e-05 *[-0.875494164452613  -0.332137142690178]

folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo';
cd(folder);

[x_car, x_geo] = receiversPositionFunction();

wgs84 = wgs84Ellipsoid("meter");

%[x, y, z] = geodetic2enu(52.23174328168711, 21.006009569400636, 231, 53.01735, 20.90708, 0, wgs84);

[x_cassino, y_cassino, z_cassino] = geodetic2enu(52.87536433653608, 20.57999572552401, 96, 53.01735, 20.90708, 0, wgs84);
x_cassino = [x_cassino, y_cassino, z_cassino].';
%------------------------

delays = [max_d23/fs, max_d24/fs];

R_cassino = [norm(x_cassino(1:2, :)-x_car(1:2, 3)), norm(x_cassino(1:2, :)-x_car(1:2, 4)), norm(x_cassino(1:2, :)-x_car(1:2, 5))];


Real_TOAs = R_cassino/c;

Real_TDOAs = [-Real_TOAs(1)+Real_TOAs(2), -Real_TOAs(1)+Real_TOAs(3)]

errs_TDOAs = Real_TDOAs - TDOAs

% corrected_TDOAs = [TDOAs(1) + 295e-9, TDOAs(2) - 451e-9]

% TDOAs = corrected_TDOAs;
%------------------------
[x_hat_opt, fval] = getXhat(TDOAs, x_car, c, 10);


surf_x_range = -25000:50:5000;
surf_y_range = -25000:50:5000;

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

disp(x_hat_opt)
disp('estymowane współżędne: ')
[lon, lat, h] = enu2geodetic(x_hat_opt(1), x_hat_opt(2), 50, 53.01735, 20.90708, 0, wgs84);
disp([lon, lat, h])

error = sqrt((x_hat_opt(1)-x_cassino(1))^2 + (x_hat_opt(2)-x_cassino(2))^2)
