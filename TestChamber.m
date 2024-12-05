%Wczytanie sygnału dvbt
[signal_dvbt, fs, fc] = loadDVBTFunction('dvbt_signal.mat');

%Prędkość propagacji sygnału
c = 299792458;

%skrócenie sygnału do 2ms
sig_time = (numel(signal_dvbt)/double(fs))*1000; %in ms

sig_time_new = numel(signal_dvbt)/50;

signal = signal_dvbt(int64(numel(signal_dvbt)/3):int64(numel(signal_dvbt)/3 + sig_time_new - 1));

%przesunięcie sygnałów
distance = 100; %odległość w m
delay = distance/c; %opóźnienie w s
delay_samples = delay*double(fs); %opóźnienie w próbkach

sig_drift = delay_samples - fix(delay_samples);

xq = 1 + sig_drift:1:numel(signal)-1+sig_drift;

signal_il = interp1(signal, xq);

% signal2 = [zeros(1, round(delay_samples)), signal];
signal3 = [zeros(1, round(delay_samples)), signal_il];

%dodanie szumu
SNR_eqalizer = 46.327; %wyrównanie poziomów sygnału i szumu
SNR = SNR_eqalizer + 3;

dev_iter = 1000; %ile razy powtórzone jest obliczanie błędu estymaty, żeby obliczyć błąd śr i dewiację

est_errors = zeros(1, dev_iter);
lag_errors = zeros(1, dev_iter);
for i = 1:dev_iter

    noise1 = (randn(1, numel(signal)) + 1i*randn(1, numel(signal)))/db2mag(SNR);
    noise2 = (randn(1, numel(signal3)) + 1i*randn(1, numel(signal3)))/db2mag(SNR);
    
    signaln = signal + noise1;
    signal3n = signal3 + noise2;
    
    % snr_value = snr(signal, noise1);
    
    %korelacja
    [corrval, lag] = xcorr(signaln, signal3n);
    
    max_lag = -lag(corrval == max(corrval));
    est_delay = double(max_lag)/double(fs);
    
    est_errors(i) = abs(delay - est_delay); %błąd estymaty w sekundach
    lag_errors(i) = abs(delay_samples - max_lag);
end

figure('Name', 'Errors [s]')
plot(est_errors)

figure('Name', 'Errors in samples')
plot(lag_errors)

mean_lag = mean(lag_errors);
dev_lag = std(lag_errors);

mean_error = mean(est_errors);
dev_error = std(est_errors);


