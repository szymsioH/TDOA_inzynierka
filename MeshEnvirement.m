clear;

%Wczytanie sygnału dvbt
[signal_dvbt, fs, fc] = loadDVBTFunction('dvbt_signal.mat');

%Wczytanie lokalizacji odbiorników
[x_car, x_geo] = receiversPositionFunction();

%Prędkość propagacji sygnału
c = 299792458;

%Stworzenie siatki nadajników
mesh_range = -30000:5000:30000;
[xsources, ysources] = meshgrid(mesh_range, mesh_range);

SNR_dB = calcSnrFunction(c, 100)

deviation_m = sqrt(10000^2/(10^(SNR_dB/10)))

function SNR_dB = calcSnrFunction(c, distance)
    %Dla Warszawa Raszyn:
    ERP_lin = 10000;
    ERP_dBW = 10*log(ERP_lin)
    f = 690*10^6;
    B = 8*10^6;
    Nt_dBW = (-174 + 10*log(B)) - 30
    Lfs_dB = 20*log((4*pi*distance)/(c/f))
    Pr_dB = ERP_dBW - Lfs_dB
    SNR_dB = Pr_dB - Nt_dBW;
end