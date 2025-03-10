clear all;

tic

folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo';
cd(folder);

%Wczytanie sygnału dvbt
[signal_dvbt, fs, fc] = loadDVBTFunction('dvbt_signal.mat');

%Wczytanie danych dotyczących błędów
err_folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo\errors_and_snr_tables';
cd(err_folder);

file_name = '1000iter_0m.mat';

if exist(file_name, 'file') ~= 2
    error('Plik %s nie istnieje.', file_name);
end

snrs_data = load(file_name);

deviations = transpose(snrs_data.allerr_list(2, :));
SNRs_list = transpose(snrs_data.SNRs_list);

%Powrót do folderu głównego
folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo';
cd(folder);

%Wczytanie lokalizacji odbiorników
[x_car, x_geo] = receiversPositionFunction();

%ustawienia fminunc
% x0 = [0; 0];
% options = optimoptions('fminunc','Algorithm','quasi-newton','Display','off');

%Prędkość propagacji sygnału
c = 299792458;

%obliczenie odchylenia stand. błędów synchronizacji
syn_n_sigma = double(1/(2*double(fs)));
% syn_n_sigma = 25e-09;

%Ustawienia modelu
os_type = 0; %rodzaj interpolacji (0, 1, 2, 3, 4)
os_value = 1;
co_value = 1;
iter_m = 30; %iteracje
is_synchro = 1; % 0 - bez błędów synchronizacji, 1 - z błędami
const_SNR = 30;

xsources = -5000:200:5000;
ysources = -5000:200:5000;

dev_mesh = zeros(numel(ysources), numel(xsources));
mean_mesh = zeros(numel(ysources), numel(xsources));
rms_mesh = zeros(numel(ysources), numel(xsources));


for x = xsources
    for y = ysources

        R = [norm(x_car(1:2, 3).'-[x, y]);
                norm(x_car(1:2, 4).'-[x, y]);
                norm(x_car(1:2, 5).'-[x, y])];


        

        %SNR stały=============================
        SNR_dB = const_SNR;
        diffs = abs(SNRs_list - SNR_dB);
        [~, sortedIndices] = sort(diffs);
        closest_devs = deviations(sortedIndices(1:2));
        closest_SNRs = SNRs_list(sortedIndices(1:2));
        devs1 = interp1(closest_SNRs, closest_devs, SNR_dB);
        devs = [devs1, devs1, devs1];

        %SNR zależny od odległości=============
%         devs = zeros(1, 3);
%         SNR_dB = calcSnrFunction(c, fc, R);
%         for d = 1:3
% %             devs(d) = getDevsFunction(signal_dvbt, os_type, os_value, co_value, fs, SNR_dB(d), R(d));
%             diffs = abs(SNRs_list - SNR_dB(d));
%             [~, sortedIndices] = sort(diffs);
%             closest_devs = deviations(sortedIndices(1:2));
%             closest_SNRs = SNRs_list(sortedIndices(1:2));
%             devs(d) = interp1(closest_SNRs, closest_devs, SNR_dB(d));
%         end

        TOAs = R/c;
        
        est_errors = zeros(1, iter_m);
        for i = 1:iter_m
            %TDOAs: 1 - s-w, 2 - s-i
            noises = ((2*rand(3, 1))-1).*(devs.');

%             noises = [randi([-devs(1) devs(1)]);
%                 randi([-devs(2) devs(2)]);
%                 randi([-devs(3) devs(3)]);
%                 randi([-devs(4) devs(4)])];

            if is_synchro == 0
                noises2 = zeros(3, 1);
            elseif is_synchro == 1
                noises2 = ((2*rand(3, 1))-1)*syn_n_sigma;

            end

            TOAs = TOAs + noises + noises2;

            TDOAs = [-TOAs(1)+TOAs(2); -TOAs(1)+TOAs(3)];

            %x0 = getWLSestimate(TDOAs, x_car, c);

            source_idxs = [find(xsources==x), find(ysources==y)];
            
            [x_hat_opt, fval] = getXhat(TDOAs, x_car, c, 1);

            est_errors(i) = norm(x_hat_opt - [x; y]);
        end
        dev_mesh(ysources==y, xsources==x) = std(est_errors);
        mean_mesh(ysources==y, xsources==x) = mean(est_errors);
        rms_mesh(ysources==y, xsources==x) = rms(est_errors);
    end
end


figure('Name', 'Standard Deviation');
clim2 = [0 5000];
imagesc(xsources, ysources, dev_mesh, clim2)
colorbar;
xlabel('x [m]')
ylabel('y [m]')
axis xy
title('Odchylenie Standardowe [m] względem położenia nadajnika')
hold on
plot(x_car(1, 3:5).', x_car(2, 3:5).', '^k', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');

wgs84 = wgs84Ellipsoid("meter");
[x_cassino, y_cassino, z_cassino] = geodetic2enu(52.87536433653608, 20.57999572552401, 96, 53.01735, 20.90708, 0, wgs84);

% figure('Name', 'Root Mean Squere');
% clim3 = [0 5000];
% imagesc(xsources, ysources, mean_mesh, clim3)
% colorbar;
% xlabel('x [m]')
% ylabel('y [m]')
% axis xy
% title('Średnia wartość błędu [m]')
% hold on
% plot(x_car(1, 3:5).', x_car(2, 3:5).', '^k', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');
% hold on
% % plot(x_cassino, y_cassino, 'g.', 'MarkerSize', 25)
% shading interp;
% % end


figure('Name', 'Errors');
clim3 = [0 5000];
imagesc(xsources/1000, ysources/1000, mean_mesh, clim3)
colorbar;
xlabel('x [km]')
ylabel('y [km]')
axis xy
title('Mean value of estimation errors [m]')
hold on
plot(x_car(1, 3:5).'/1000, x_car(2, 3:5).'/1000, '^k', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');
hold on
% plot(x_cassino, y_cassino, 'g.', 'MarkerSize', 25)
shading interp;

toc

% R2 = linspace(1, 100e3, 1000);
% 
% SNR_dB = calcSnrFunction(c, fc, R2);
% 
% figure;
% plot(R2/1e3, SNR_dB, 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.8)
% xlabel('R [km]')
% ylabel('SNR [dB]')
% title('Poziom SNR [dB] względem odległości od nadajnika [km]')
% grid on;

function SNR_dB = calcSnrFunction(c, fc, R)
    %Dla Warszawa Raszyn:
    ERP_lin = 50e3;
    ERP_dBW = 10*log10(ERP_lin);
    T0 = 2300;
    Gr = 1; % zysk anteny odbiorczej
    f = fc;
    lamb = c/f;
    B = 8*10^6;
    Nt_dBW = (-174 + 10*log10(B)) - 30;
%     Lfs_dB = 20*log((4*pi*R)/(lamb));
    Lfs_dB = 32.44 + 20*log10(f/10^6) + 20*log10(R/1000);
    Pr_dB = ERP_dBW - Lfs_dB;
    SNR_dB = Pr_dB - Nt_dBW;

%     Psignal = ERP_lin./(4*pi*R.^2)*lamb^2*Gr/(4*pi);
%     Pnoise = 1.380e-23*T0*B;
%     SNR = Psignal/Pnoise;
%     SNR_dB = 10*log10(SNR);

end