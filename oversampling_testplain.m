

fs = double(10e+6);
c = 299792458;

% Parametry sygnału
fs = 1000; % Częstotliwość próbkowania [Hz]
t = 0:1/fs:1; % Czas w sekundach
t_ms = t * 1000; % Czas w milisekundach
N = length(t); % Liczba próbek

% Impuls prostokątny (szerokość 50 próbek, początek od 250 próbki)
impulse_width = 50;
impulse_start = 250;
impulse = zeros(size(t));
impulse(impulse_start:impulse_start+impulse_width-1) = 1;

% Dodanie szumu obu impulsom
noise_level = 0.1; % Poziom szumu
impulse_noisy = impulse + noise_level * randn(size(t));
impulse_shifted_noisy = circshift(impulse_noisy, 100) + noise_level * randn(size(t));

% Korelacja krzyżowa
[corr_xy, lags] = xcorr(impulse_noisy, impulse_shifted_noisy, 'normalized');

% Wyświetlanie wykresów
figure;
subplot(3,1,1);
plot(t_ms, impulse_noisy);
title('Impuls oryginalny (zaszumiony)');
xlabel('Czas [ms]');
ylabel('Amplituda');
grid on

subplot(3,1,2);
plot(t_ms, impulse_shifted_noisy);
title('Impuls przesunięty (zaszumiony)');
xlabel('Czas [ms]');
ylabel('Amplituda');
grid on

subplot(3,1,3);
plot(lags, corr_xy); % Dostosowanie długości wektora czasu dla korelacji
title('Korelacja krzyżowa impulsów zaszumionych');
xlabel('Przesunięcie [ms]');
ylabel('Wartość korelacji');
xlim([-600 600])
grid on
% files2 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary_przasnysz\sygnały\L2\*.usf');
% files3 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary_przasnysz\sygnały\L3\*.usf');
% files4 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary_przasnysz\sygnały\L4\*.usf');
% 
% folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary';
% cd(folder);
% 
% [header2, data2] = USF.readUSFFile([files2(1).folder filesep files2(1).name]);
% [header3, data3] = USF.readUSFFile([files3(1).folder filesep files3(1).name]);
% [header4, data4] = USF.readUSFFile([files4(1).folder filesep files4(1).name]);
% 
% 
% data2 = double(data2);
% data3 = double(data3);
% data4 = double(data4);
% 
% [corrval23, lag23] = xcorr(data2, data4, 1000, 'normalized');

% figure
% plot(lag23, db(corrval23))
% xlabel('Opóźnienie [w próbkach]')
% ylabel('Wartość korelacji [dB]')
% title('Korelacja sygnałów z ,,Wieży" i ,,Internatu"')
% % figure
% % plot(lag23, db(imag(corrval23)))
% 
% [corrval23, lag23] = xcorr(data2, data4, 'normalized');
% 
% figure
% plot(lag23, db(corrval23))
% xlabel('Opóźnienie [w próbkach]')
% ylabel('Wartość korelacji [dB]')
% title('Korelacja sygnałów z ,,Wieży" i ,,Internatu"')



% % Obliczenie liczby próbek
% N = length(data2);
% fc = 226500000;
% 
% % Obliczenie transformaty Fouriera
% widmo = fft(data2);
% 
% % Przesunięcie widma, aby było symetryczne
% widmo_shift = fftshift(widmo);
% 
% % Obliczenie osi częstotliwości
% f = (-N/2:N/2-1) * (double(fs) / N);
% 
% % Opcjonalnie: uwzględnienie częstotliwości nośnej
% f_nosna = f + double(fc);
% figure;
% plot(f_nosna/1e+6, db(abs(widmo_shift)));
% xlabel('Częstotliwość (MHz)');
% ylabel('Amplituda');
% xlim([221 232])
% title('Widmo sygnału DVBT');
% grid on;

% x1 = 1:10;
% x2 = 1.4:1:9.4;
% 
% x = 1:0.1:10;
% y = sin(x);
% 
% y2 = interp1(x1, sin(x1), x2);
% 
% figure
% p1 = plot(x, y, 'r--');
% hold on
% s1 = stem(x1, sin(x1), 'Color', [0 0.4470 0.7410], 'LineWidth', 1.2);
% s2 = stem(x2, y2, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.1);
% grid on
% xlabel('Kolejne próbki')
% ylabel('Amplituda sygnału')
% legend([p1, s1, s2], {'Rzeczywisty przebieg sygnału', 'Odebrany sygnał dyskretny', 'Sygnał przesunięty'})
% title('Interpolacja wartości przesunięć sygnału')
