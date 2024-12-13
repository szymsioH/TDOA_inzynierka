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

% snr_mesh = zeros(numel(ysources(:, 1), xsources(1, :)));
% for j = 1:numel(ysources(:, 1))
%     for i = 1:numel(xsources(1, :))
%         trans = [xsources(1, i), ysources(j, 1)];
%         rec = x_car(1:2, 2);
%         d = abs(norm(rec-trans));
%         SNR_dB = calcSnrFunction(c, d);
%         snr_mesh(i, j) = SNR_dB;
%     end
% end
% 
% figure;
% imagesc(xsources(1, :), ysources(:, 1), snr_mesh)
% colorbar;
% xlabel('m')
% ylabel('m')
% title('Wartości SNR dla położeń nadajnika względem Oblotu')
% hold on
% plot(0, 0, '^black', 'MarkerSize', 5, 'MarkerFaceColor', 'yellow')

R = linspace(1, 100e3, 1000);

SNR_dB = calcSnrFunction(c, R);

figure;
plot(R/1e3, SNR_dB)
xlabel('R [km]')
ylabel('SNR [dB]')
grid on;

function SNR_dB = calcSnrFunction(c, R)
    %Dla Warszawa Raszyn:
    ERP_lin = 100000;
    ERP_dBW = 10*log10(ERP_lin);
    T0 = 2300;
    Gr = 1; % zysk anteny odbiorczej
    f = 690*10^6;
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