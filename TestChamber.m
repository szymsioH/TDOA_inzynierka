clear workspace;

tic

distance = 1000; %odległość w m
os_type = 2; %rodzaj interpolacji
os_value = 2;
co_value = 2;
iters = 50; %iteracje

[allerr_list, SNRs_list, type_name, corr_osval] = getErrsToSnrs(distance, os_type, os_value, co_value, iters);

figure('Name', 'Mean Error to SNR');
plot(SNRs_list, allerr_list(1, :)*10^(9)); %w ns
title([num2str(distance), 'm, ', num2str(os_value), '*fs, ', num2str(iters),  'iteracji, ', type_name, corr_osval])
xlabel('SNR [dB]')
ylabel('Średnia wartość błędu [ns]')

figure('Name', 'Deviations to SNR');
plot(SNRs_list, allerr_list(2, :)*10^(9)); %w ns
title([num2str(distance), 'm, ', num2str(os_value), '*fs, ', num2str(iters),  'iteracji, ', type_name, corr_osval])
xlabel('SNR [dB]')
ylabel('Odchylenie standardowe [ns]')

figure('Name', 'RMS to SNR');
plot(SNRs_list, allerr_list(3, :)*10^(9)); %w ns
title([num2str(distance), 'm, ', num2str(os_value), '*fs, ', num2str(iters),  'iteracji, ', type_name, corr_osval])
xlabel('SNR [dB]')
ylabel('RMS [ns]')

toc

function [allerr_list, SNRs_list, type_name, corr_osval] = getErrsToSnrs(distance, os_type, os_value, co_value, iters)

    %Wczytanie sygnału dvbt
    [signal_dvbt, fs, fc] = loadDVBTFunction('dvbt_signal.mat');
    
    %Prędkość propagacji sygnału
    c = 299792458;
    
    %skrócenie sygnału do 2ms
    sig_time_new = numel(signal_dvbt)/50;
    
    signal = signal_dvbt(int64(numel(signal_dvbt)/3):int64(numel(signal_dvbt)/3 + sig_time_new - 1));
    
    %przesunięcie sygnałów
    delay = distance/c; %opóźnienie w s
    
    delay_samples = delay*double(fs); %opóźnienie w próbkach
    
    sig_drift = delay_samples - fix(delay_samples);
    
    signal2 = [zeros(1, round(delay_samples)), signal];
    signal = [signal, zeros(1, round(delay_samples))];
    
    type_name = '';
    corr_osval = '';
    
    switch os_type
        case 1
            %powielenie próbek sygnału
            type_name = 'repelem';
            signal = repelem(signal, os_value);
            signal2 = repelem(signal2, os_value);
        case 2
            %interpolacja liniowa
            type_name = 'interp1';
            range = 1:(1/os_value):numel(signal);
            signal = interp1(signal, range);
            range2 = 1:(1/os_value):numel(signal2);
            signal2 = interp1(signal2, range2);
        case 3
            %interpolacja fourierowska
            type_name = 'interpfr';
            signal = interpft(signal, os_value*numel(signal));
            signal2 = interpft(signal2, os_value*numel(signal2));
        case 4
            %zwiększenie liczby próbek z dopasowaniem filtra dolnoprzepustowego
            type_name = 'resample';
            signal = resample(signal, double(os_value), 1);
            signal2 = resample(signal2, double(os_value), 1);
        otherwise
            os_value = 1;
    end
    fs = fs * os_value;
    
    % SNR_list1 = -30:2:-24;
    % SNR_list2 = -23.5:0.5:0.5;
    % SNR_list3 = 1:1:4;
    % SNR_list4 = 5:5:20;
    
    SNR_list1 = -30:2:-24;
    SNR_list2 = -23.5:0.5:0.5;
    SNR_list3 = 1:1:4;
    SNR_list4 = 5:5:160;
    
    iter_index = 0;
    
    allerr_list = zeros(3, numel([SNR_list1, SNR_list2, SNR_list3, SNR_list4])); %wiersze: 1 - mean, 2 - std, 3 - rms
    SNRs_list = zeros(1, numel(allerr_list(1, :)));
    
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
    
        for j = SNR_list
            iter_index = iter_index + 1;
            est_errors = zeros(1, iters);
            for i = 1:iters
            
                noise1 = (randn(1, numel(signal)) + 1i*randn(1, numel(signal)));
                noise2 = (randn(1, numel(signal2)) + 1i*randn(1, numel(signal2)));
    
                check1 = snr(signal, noise1);
    
%                 db2mag(-SNR_eqalizer1);
    
                signaln = signal.*db2mag(-(check1-j));
                signal2n = signal2.*db2mag(-(check1-j));
    
%                 check3 = snr(signaln, noise1);
%                 check4 = snr(signal2n, noise2);
                
                signaln = signaln + noise1;
                signal2n = signal2n + noise2;
    
%                 check5 = snr(signaln, signal2n);
                
                % snr_value = snr(signal, noise1);
                
                %korelacja
                [corrval, lag] = xcorr(signaln, signal2n);
        
                if co_value == 1
                    max_lag = -lag(corrval == max(corrval));
                else
                    %nadpróbkowanie korelacji
                    corr_osval = [' ov sampl * ', num2str(co_value)];
                    rangecorr = min(lag):(1/co_value):max(lag);
                    corrval_itp = interp1(lag, corrval, rangecorr, 'spline');
        
%                     [max_corr, max_idx] = max(corrval_itp);
                    max_lag = -rangecorr(corrval_itp == max(corrval_itp));
                end
                
                est_delay = double(max_lag)/(double(fs)); % wyestymowane opóźnienie w s
                
                est_errors(i) = abs(delay - est_delay); %błąd estymaty w sekundach
            end
        
            allerr_list(1, iter_index) = mean(est_errors);
            allerr_list(2, iter_index) = std(est_errors);
            allerr_list(3, iter_index) = rms(est_errors);
    
            SNRs_list(1, iter_index) = j;
        end
    end
    
    
    
    range_temp = 1:find(SNRs_list == SNR_list2(1));
    range_temp1 = SNR_list1(1):0.5:SNR_list2(1);
    detailed_errs1 = [interp1([SNR_list1, SNR_list2(1)], allerr_list(1, range_temp), range_temp1);
        interp1([SNR_list1, SNR_list2(1)], allerr_list(2, range_temp), range_temp1);
        interp1([SNR_list1, SNR_list2(1)], allerr_list(3, range_temp), range_temp1)];
    detailed_errs1 = detailed_errs1(:, 1:end-1);
    
    range_temp = find(SNRs_list == SNR_list2(end)):find(SNRs_list == SNR_list4(1));
    range_temp3 = SNR_list2(end):0.5:SNR_list4(1);
    detailed_errs3 = [interp1([SNR_list2(end), SNR_list3, SNR_list4(1)], allerr_list(1, range_temp), range_temp3);
        interp1([SNR_list2(end), SNR_list3, SNR_list4(1)], allerr_list(2, range_temp), range_temp3);
        interp1([SNR_list2(end), SNR_list3, SNR_list4(1)], allerr_list(3, range_temp), range_temp3)];
    detailed_errs3 = detailed_errs3(:, 2:end-1);
    
    range_temp = find(SNRs_list == SNR_list4(1)):find(SNRs_list == SNR_list4(end));
    range_temp4 = SNR_list4(1):0.5:SNR_list4(end);
    detailed_errs4 = [interp1(SNR_list4, allerr_list(1, range_temp), range_temp4);
        interp1(SNR_list4, allerr_list(2, range_temp), range_temp4);
        interp1(SNR_list4, allerr_list(3, range_temp), range_temp4)];
    
    allerr_list = [detailed_errs1, allerr_list(:, find(SNRs_list == SNR_list2(1)):find(SNRs_list == SNR_list2(end))), detailed_errs3, detailed_errs4];
    SNRs_list = SNR_list1(1):0.5:SNR_list4(end);
end