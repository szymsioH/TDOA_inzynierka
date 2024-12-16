function [allerr_list, SNRs_list, type_name, corr_osval] = getErrsToSnrs(distance, SNR_list, os_type, os_value, co_value, iters)

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


    signald = interp1(1:1:numel(signal), signal, 1+sig_drift:1:numel(signal)-1+sig_drift, 'cubic');
    
    signal2 = [zeros(1, round(delay_samples)), signald];
    signal = [signal(1:end-1), zeros(1, round(delay_samples))];
    
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
            signal = resample(double(signal), double(os_value), 1);
            signal2 = resample(double(signal2), double(os_value), 1);
        otherwise
            os_value = 1;
    end
    fs = fs * os_value;
    
%     SNR_list1 = -30:2:-24;
%     SNR_list2 = -23.5:0.5:0.5;
%     SNR_list3 = 1:1:4;
%     SNR_list4 = 5:5:160;
    
    iter_index = 0;
    
    allerr_list = zeros(3, numel(SNR_list)); %wiersze: 1 - mean, 2 - std, 3 - rms
    
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
%                     corrval_itp = resample(double(corrval), co_value, 1);
    
%                     [max_corr, max_idx] = max(corrval_itp);
                max_lag = -rangecorr(corrval_itp == max(corrval_itp));
            end
            
            est_delay = double(max_lag)/(double(fs)); % wyestymowane opóźnienie w s
            
            est_errors(i) = abs(delay - est_delay); %błąd estymaty w sekundach
        end
    
        allerr_list(1, iter_index) = mean(est_errors);
        allerr_list(2, iter_index) = std(est_errors);
        allerr_list(3, iter_index) = rms(est_errors);

    end
    
    range_new = SNR_list(1):0.5:SNR_list(end);
    detailed_allerr = [interp1(SNR_list, allerr_list(1, :), range_new);
        interp1(SNR_list, allerr_list(2, :), range_new);
        interp1(SNR_list, allerr_list(3, :), range_new)];
    
    allerr_list = detailed_allerr;
    SNRs_list = SNR_list(1):0.5:SNR_list(end);
end