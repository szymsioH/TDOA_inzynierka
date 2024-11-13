%wczytanie pliku z sygnałem dvbt

[signal_dvbt, fs, fc] = loadDVBTFunction('dvbt_signal.mat');

%czestotliwośc próbkowania

% fs = 10^8;
duration = 0.15; % 150 ms

%prędkośc propagacji sygnału
c = 299792458;

%Obliczanie ENU:
wgs84 = wgs84Ellipsoid("meter");

%NADAJNIKI I ODBIORNIKI
%--------------------------------------------------
[x_car, x_geo] = receiversPositionFunction();

sig_source = signalSourceFunction(17);
%--------------------------------------------------
%OPÓŹNIENIA
delays = signalSimFunction(x_car, x_geo, sig_source, c);

%--------------------------------------------------------------------------
%KORELACJE                                                                |
%--------------------------------------------------------------------------

TDOAs = getTDOAsXcorr(duration, delays, fs, signal_dvbt, -3);

%==========================================================================
%TOA - TOA                                                                |
%==========================================================================

% TDOAs = getTDOAsTOAs(delays);

%--------------------------------------------------------------------------

TDOAs;

x0 = [0; 0; 0];
options = optimoptions('fminunc','Algorithm','quasi-newton','Display','iter');

[x_hat_opt, fval] = fminunc(@(x_hat) costFunctionLS_TDOA(x_hat, x_car, TDOAs, c), x0, options);

% options = optimset('Display', 'iter');
% x_hat_opt = fminsearch(@(x_hat) costFunctionLS_TDOA(x_hat, x_car, TDOAs, c), x0, options);

x_nad = [xEast_nadajnik, x_hat_opt(1)];
y_nad = [yNorth_nadajnik, x_hat_opt(2)];
%z_nad = [zUp_nadajnik, x_hat_opt(3)];
z_nad = [zUp_nadajnik, 120];

figure('Name', 'fminunc estimation');

scatter3(x_car(1, 2:5), x_car(2, 2:5), x_car(3, 2:5), 100, 'filled');
xlabel('East [m]');
ylabel('North [m]');
zlabel('Hight [m]');
title('Estymata lokalizacji stacji nadawczej');
grid on;
hold on
plot3(xEast_nadajnik, yNorth_nadajnik, zUp_nadajnik, 'r.', 'MarkerSize', 20)
hold on
plot3(x_hat_opt(1), x_hat_opt(2), x_hat_opt(3),'g.', 'MarkerSize', 20)
% plot3(x_hat_opt(1), x_hat_opt(2), 120,'g.', 'MarkerSize', 20)
legend('Odbiorniki', 'Nadajnik (wpisany)', 'Nadajnik (estymata)');


%-----------------------------------------------------------------------------
% WYKRES FUNKCJI KOSZTU:
%-----------------------------------------------------------------------------

min_x_receiver = min(x_car(1, 2:5));
max_x_receiver = max(x_car(1, 2:5));
min_y_receiver = min(x_car(2, 2:5));
max_y_receiver = max(x_car(2, 2:5));

min_x_surf = 0;
max_x_surf = 0;
min_y_surf = 0;
max_y_surf = 0;

if min_x_receiver > xEast_nadajnik
    min_x_surf = xEast_nadajnik;
    max_x_surf = max_x_receiver;
elseif xEast_nadajnik > max_x_receiver
    max_x_surf = xEast_nadajnik;
    min_x_surf = min_x_receiver;
elseif (min_x_receiver <= xEast_nadajnik) && (xEast_nadajnik <= max_x_receiver)
    max_x_surf = max_x_receiver;
    min_x_surf = min_x_receiver;
end

if min_y_receiver > yNorth_nadajnik
    min_y_surf = yNorth_nadajnik;
    max_y_surf = max_y_receiver;
elseif yNorth_nadajnik > max_y_receiver
    max_y_surf = yNorth_nadajnik;
    min_y_surf = min_y_receiver;
elseif (min_y_receiver <= yNorth_nadajnik) && (yNorth_nadajnik <= max_y_receiver)
    max_y_surf = max_y_receiver;
    min_y_surf = min_y_receiver;
end


% surf_x_range = min_x_surf-10:(max_x_surf-min_x_surf)/10^2:max_x_surf+10;
% surf_y_range = min_y_surf-10:(max_y_surf-min_y_surf)/10^2:max_y_surf+10;

surf_x_range = min_x_surf-100:20:max_x_surf+100;
surf_y_range = min_y_surf-100:20:max_y_surf+100;

% surf_x_range = -10000:20:10000;
% surf_y_range = -100000:20:max_y_surf+100;

[X_testpoints, Y_testpoints] = meshgrid(surf_x_range, surf_y_range);
Z_testpoints = zeros(size(X_testpoints));

for i = 1:numel(X_testpoints)
    x_hat = [X_testpoints(i); Y_testpoints(i); zUp_nadajnik];
    %x_hat = [X_testpoints(i); Y_testpoints(i)];
    Z_testpoints(i) = costFunctionLS_TDOA(x_hat, x_car, TDOAs, c);
end

[minZ, minIdx] = min(Z_testpoints(:));
[minX, minY] = ind2sub(size(Z_testpoints), minIdx);
x_optimal = X_testpoints(minX, minY);
y_optimal = Y_testpoints(minX, minY);

figure('Name', 'Cost Function Values Mesh'); 
surf(X_testpoints, Y_testpoints, Z_testpoints);
colorbar;
shading interp;
hold on;

plot3(x_optimal, y_optimal, minZ, 'g.', 'MarkerSize', 20);
hold on;

[maxZ, maxIdx] = max(Z_testpoints(:));
maxZhub = [maxZ maxZ maxZ maxZ];

plot3(x_car(1, 2:5), x_car(2, 2:5), maxZhub, '^black', 'MarkerSize', 5, 'MarkerFaceColor', 'yellow');

hold on
plot3(xEast_nadajnik, yNorth_nadajnik, maxZhub, 'r.', 'MarkerSize', 20);
legend(' ', 'Wyestymowana lokalizacja nad.', 'Odbiorniki', 'Realna lokalizacja nad.');

% Siatka nadajników:
% est_errors = getSourcesMesh(x_car, c, fs, signal_dvbt, duration);

% Wyświetl wyniki
disp('Wpisane współżędne nadajnika (kartezjańskie):');
[xEast_nadajnik,yNorth_nadajnik,zUp_nadajnik] = geodetic2enu(sig_source(1),sig_source(2),sig_source(3),x_geo(1, 1),x_geo(2, 1),x_geo(3, 1),wgs84);
nad_coord = [xEast_nadajnik; yNorth_nadajnik; zUp_nadajnik];
disp(nad_coord);
disp('Wyestymowane współżędne nadajnika (kartezjańskie):');
disp(x_hat_opt);
disp('Wpisane koordynaty nadajnika (geodetic)');
disp(sig_source(1));
disp(sig_source(2));
disp(sig_source(3));
disp('Wyestymowane koordynaty nadajnika (geodetic):');
format shortG
[lat_miara,lon_miara,h_miara] = enu2geodetic(x_hat_opt(1),x_hat_opt(2),x_hat_opt(3),x_geo(1, 1),x_geo(2, 1),x_geo(3, 1),wgs84);
% [lat_miara,lon_miara,h_miara] = enu2geodetic(x_hat_opt(1),x_hat_opt(2),120,x_geo(1, 1),x_geo(2, 1),x_geo(3, 1),wgs84);
disp(lat_miara);
disp(lon_miara);
disp(h_miara);
disp('Błąd estymaty (fminunc) [w metrach]:');
disp(norm(x_hat_opt(1:2) - nad_coord(1:2)));
disp('Błąd estymaty (siatka funkcji kosztu) [w metrach]:');
disp(norm([x_optimal, y_optimal] - [xEast_nadajnik, yNorth_nadajnik]));

% norm([xEast_nadajnik, yNorth_nadajnik, zUp_nadajnik] - (x_car(:, 2).'));

