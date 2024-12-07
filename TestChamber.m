clear;

%Wczytanie sygnału dvbt
[signal_dvbt, fs, fc] = loadDVBTFunction('dvbt_signal.mat');

%Prędkość propagacji sygnału
c = 299792458;

tic
%skrócenie sygnału do 2ms
sig_time = (numel(signal_dvbt)/double(fs))*1000; %in ms

sig_time_new = numel(signal_dvbt)/50;

signal = signal_dvbt(int64(numel(signal_dvbt)/3):int64(numel(signal_dvbt)/3 + sig_time_new - 1));

%przesunięcie sygnałów
distance = 10000; %odległość w m
delay = distance/c; %opóźnienie w s

os_type = 2; %rodzaj interpolacji
os_value = 10 ;
co_value = 1;
fs = fs * os_value;

delay_samples = delay*double(fs); %opóźnienie w próbkach

sig_drift = delay_samples - fix(delay_samples);

xq = 1 + sig_drift:1:numel(signal)-1+sig_drift;

signal_il = interp1(signal, xq);

signal2 = [zeros(1, round(delay_samples)), signal_il];

switch os_type
    case 1
        %powielenie próbek sygnału
        signal = repelem(signal, os_value);
        signal2 = repelem(signal2, os_value);
    case 2
        %interpolacja liniowa
        range = 1:(1/os_value):numel(signal);
        signal = interp1(signal, range);
        range2 = 1:(1/os_value):numel(signal2);
        signal2 = interp1(signal2, range2);
    case 3
        %interpolacja fourierowska
        signal = interpft(signal, os_value*numel(signal));
        signal2 = interpft(signal2, os_value*numel(signal2));
    case 4
        %zwiększenie liczby próbek z dopasowaniem filtra dolnoprzepustowego
        signal = resample(signal, os_value, 1);
        signal2 = resample(signal2, os_value, 1);
    otherwise
        os_value = 1;
end

%dodanie szumu
SNR_eqalizer = 46.327; %wyrównanie poziomów sygnału i szumu

SNR_list1 = -40:2:-24;
SNR_list2 = -23.5:0.5:0.5;
SNR_list3 = 1:1:11;
SNR_list4 = 11.5:2:29.5;


dev_iter = 100; %iteracje


for n = 1:4
    switch n
        case 1
            SNR_list = SNR_list1;
        case 2
            SNR_list = SNR_list2;
        case 3
            SNR_list = SNR_list3;
        case 4
            SNR_list = SNR_list4;
    end

    devs_list = zeros(1, numel(SNR_list)); %1 wiersz - dewiacje, 2 wiersz - błąd średni

    for j = SNR_list
        SNR = SNR_eqalizer + j;
        
        est_errors = zeros(1, dev_iter);
        lag_errors = zeros(1, dev_iter);
        for i = 1:dev_iter
        
            noise1 = (randn(1, numel(signal)) + 1i*randn(1, numel(signal)))/db2mag(SNR);
            noise2 = (randn(1, numel(signal2)) + 1i*randn(1, numel(signal2)))/db2mag(SNR);
            
            signaln = signal + noise1;
            signal2n = signal2 + noise2;
            
            % snr_value = snr(signal, noise1);
            
            %korelacja
            [corrval, lag] = xcorr(signaln, signal2n);
    
            if co_value == 1
                max_lag = -lag(corrval == max(corrval));
            else
                %nadpróbkowanie korelacji
                rangecorr = min(lag):(1/co_value):max(lag);
                corrval_itp = interp1(lag, corrval, rangecorr, 'spline');
    
                [max_corr, max_idx] = max(corrval_itp);
                max_lag = -rangecorr(corrval_itp == max(corrval_itp));
            end
            
            est_delay = double(max_lag)/double(fs);
            
            est_errors(i) = abs(delay - est_delay); %błąd estymaty w sekundach
        end
    
    % figure('Name', 'Errors [s]')
    % plot(est_errors)
    % 
    % figure('Name', 'Errors in samples')
    % plot(lag_errors)
    
    %     mean_lag = mean(lag_errors);
    %     dev_lag = std(lag_errors);
        
        mean_error = mean(est_errors);
        devs_list(1, SNR_list==j) = std(est_errors);
    end
    if numel(SNR_list) == numel(SNR_list1)
        detailed_devs = devs_list(1, :);
        detailed_SNR = SNR_list;
    else
        idx_idefiks = numel(detailed_devs(1, :)) + 1;
        detailed_devs( idx_idefiks:numel(devs_list(1, :))+idx_idefiks-1 ) = devs_list(1, :);
        detailed_SNR( idx_idefiks:numel(devs_list(1, :))+idx_idefiks-1 ) = SNR_list;
    end
end

range_temp = 1:find(detailed_SNR == SNR_list1(end));
range_temp1 = SNR_list1(1):0.5:SNR_list1(end);
detailed_devs1 = interp1(SNR_list1, detailed_devs(range_temp), range_temp1);

range_temp = find(detailed_SNR == SNR_list3(1)):find(detailed_SNR == SNR_list3(end));
range_temp3 = SNR_list3(1):0.5:SNR_list3(end);
detailed_devs3 = interp1(SNR_list3, detailed_devs(range_temp), range_temp3);

range_temp = find(detailed_SNR == SNR_list4(1)):find(detailed_SNR == SNR_list4(end));
range_temp4 = SNR_list4(1):0.5:SNR_list4(end);
detailed_devs4 = interp1(SNR_list4, detailed_devs(range_temp), range_temp4);

detailed_devs = [detailed_devs1, detailed_devs(find(detailed_SNR == SNR_list2(1)):find(detailed_SNR == SNR_list2(end))), detailed_devs3, detailed_devs4];
detailed_SNR = SNR_list1(1):0.5:SNR_list4(end);

figure('Name', 'Deviations to SNR');
plot(detailed_SNR, detailed_devs*10^(6)); %w us
title('10000m, 10fs, 500 iteracji, interpfr')
xlabel('SNR [dB]')
ylabel('Odchylenie standardowe [us]')

toc

load gong.mat y
sound(y)