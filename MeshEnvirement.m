clear workspace;

%Wczytanie sygnału dvbt
[signal_dvbt, fs, fc] = loadDVBTFunction('dvbt_signal.mat');

%Wczytanie lokalizacji odbiorników
[x_car, x_geo] = receiversPositionFunction();

%Prędkość propagacji sygnału
c = 299792458;

%Stworzenie siatki nadajników
mesh_range = -30000:500:30000;
[xsources, ysources] = meshgrid(mesh_range, mesh_range);

snr_mesh = zeros(numel(ysources(:, 1), xsources(1, :)));
for j = 1:numel(ysources(:, 1))
    for i = 1:numel(xsources(1, :))
        trans = [xsources(1, i), ysources(j, 1)];
        rec = x_car(1:2, 2);
        d = abs(norm(rec-trans));
        SNR_dB = calcSnrFunction(c, d);
        snr_mesh(i, j) = SNR_dB;
    end
end

figure;
imagesc(xsources(1, :), ysources(:, 1), snr_mesh)
colorbar;
xlabel('m')
ylabel('m')
title('Wartości SNR dla położeń nadajnika względem Oblotu')
hold on
plot(0, 0, '^black', 'MarkerSize', 5, 'MarkerFaceColor', 'yellow')

SNR_dB = calcSnrFunction(c, 1000);

function SNR_dB = calcSnrFunction(c, distance)
    %Dla Warszawa Raszyn:
    ERP_lin = 10000;
    ERP_dBW = 10*log(ERP_lin);
    f = 690*10^6;
    B = 8*10^6;
    Nt_dBW = (-174 + 10*log(B)) - 30;
    Lfs_dB = 20*log((4*pi*distance)/(c/f));
    Pr_dB = ERP_dBW - Lfs_dB;
    SNR_dB = Pr_dB - Nt_dBW;
end