clear all;

tic

folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo';
cd(folder);

%Wczytanie sygnału dvbt
[signal_dvbt, fs, fc] = loadDVBTFunction('dvbt_signal.mat');

%Wczytanie danych dotyczących błędów
err_folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo\errors_and_snr_tables';
cd(err_folder);

file_name = '200iter_10000dist_corr_os.mat';

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
x0 = [0; 0];
options = optimoptions('fminunc','Algorithm','quasi-newton','Display','off');

%Prędkość propagacji sygnału
c = 299792458;

%obliczenie odchylenia stand. błędów synchronizacji
syn_n_sigma = double(1/(2*double(fs)));

%Ustawienia modelu
os_type = 0; %rodzaj interpolacji (0, 1, 2, 3, 4)
os_value = 1;
co_value = 1;
iter_m = 30; %iteracje
is_synchro = 1; % 0 - bez błędów synchronizacji, 1 - z błędami

%Stworzenie siatki nadajników
mesh_range = -8000:250:8000;
[xsources, ysources] = meshgrid(mesh_range, mesh_range);
ysources = flip(ysources);

xsources = xsources(1, :);
ysources = ysources(:, 1).';

dev_mesh = zeros(numel(xsources), numel(ysources));
mean_mesh = zeros(numel(xsources), numel(ysources));
rms_mesh = zeros(numel(xsources), numel(ysources));

for x = xsources
    for y = ysources

        R = [norm(x_car(1:2, 2).'-[x, y]);
                norm(x_car(1:2, 3).'-[x, y]);
                norm(x_car(1:2, 4).'-[x, y]);
                norm(x_car(1:2, 5).'-[x, y])];

        SNR_dB = calcSnrFunction(c, fc, R);
        devs = zeros(1, 4);
        for d = 1:4
%             devs(d) = getDevsFunction(signal_dvbt, os_type, os_value, co_value, fs, SNR_dB(d), R(d));
            diffs = abs(SNRs_list - SNR_dB(d));
            [~, sortedIndices] = sort(diffs);
            closest_devs = deviations(sortedIndices(1:2));
            closest_SNRs = SNRs_list(sortedIndices(1:2));
            devs(d) = interp1(closest_SNRs, closest_devs, SNR_dB(d));
        end

        TOAs = R/c;
        
        est_errors = zeros(1, iter_m);
        for i = 1:iter_m
            %TDOAs: 1 - o-w, 2 - o-i, 3 - u-s
            noises = ((2*rand(4, 1))-1).*(devs.');

%             noises = [randi([-devs(1) devs(1)]);
%                 randi([-devs(2) devs(2)]);
%                 randi([-devs(3) devs(3)]);
%                 randi([-devs(4) devs(4)])];

            if is_synchro == 0
                noises2 = zeros(4, 1);
            elseif is_synchro == 1
                noises2 = ((2*rand(4, 1))-1)*syn_n_sigma;

            end

            TOAs = TOAs + noises + noises2;

            TDOAs = [-TOAs(1)+TOAs(2); -TOAs(1)+TOAs(3); -TOAs(1)+TOAs(4)];
            
            [x_hat_opt, fval] = fminunc(@(x_hat) costFunctionLS_TDOA(x_hat, x_car, TDOAs, c), x0, options);

            est_errors(i) = norm(x_hat_opt - [x; y]);
        end
        dev_mesh(xsources==x, ysources==y) = std(est_errors);
        mean_mesh(xsources==x, ysources==y) = mean(est_errors);
        rms_mesh(xsources==x, ysources==y) = rms(est_errors);
    end
end

figure('Name', 'Mean Error');
clim1 = [0 4000];
imagesc(xsources, ysources, mean_mesh, clim1)
colorbar;
xlabel('x [m]')
ylabel('y [m]')
axis xy
title('Błąd średni [m] względem położenia nadajnika')
hold on
plot(x_car(1, 2:5).', x_car(2, 2:5).', '^k', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');

figure('Name', 'Standard Deviation');
%clim2 = [10e-3 2000];
imagesc(xsources, ysources, dev_mesh)
colorbar;
xlabel('x [m]')
ylabel('y [m]')
axis xy
title('Odchylenie Standardowe [m] względem położenia nadajnika')
hold on
plot(x_car(1, 2:5).', x_car(2, 2:5).', '^k', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');

figure('Name', 'Root Mean Squere');
clim3 = [0 4000];
imagesc(xsources, ysources, rms_mesh, clim3)
colorbar;
xlabel('x [m]')
ylabel('y [m]')
axis xy
title('Błąd Średniokwadratowy [m] względem położenia nadajnika')
hold on
plot(x_car(1, 2:5).', x_car(2, 2:5).', '^k', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');

toc

% R2 = linspace(1, 100e3, 1000);
% 
% SNR_dB = calcSnrFunction(c, fc, R2);
% 
% figure;
% plot(R2/1e3, SNR_dB)
% xlabel('R [km]')
% ylabel('SNR [dB]')
% title('Poziom SNR [dB] względem odległości od nadajnika [km]')
% grid on;

function SNR_dB = calcSnrFunction(c, fc, R)
    %Dla Warszawa Raszyn:
    ERP_lin = 100000;
    ERP_dBW = 10*log10(ERP_lin);
    T0 = 2300;
    Gr = 1; % zysk anteny odbiorczej
    f = fc;
    lamb = c/f;
    B = 8*10^6;
%     Nt_dBW = (-174 + 10*log10(B)) - 30;
% %     Lfs_dB = 20*log((4*pi*R)/(lamb));
%     Lfs_dB = 32.44 + 20*log10(f/10^6) + 20*log10(R/1000);
%     Pr_dB = ERP_dBW - Lfs_dB;
%     SNR_dB = Pr_dB - Nt_dBW;

    Psignal = ERP_lin./(4*pi*R.^2)*lamb^2*Gr/(4*pi);
    Pnoise = 1.380e-23*T0*B;
    SNR = Psignal/Pnoise;
    SNR_dB = 10*log10(SNR);

end