function devs = getDevsFunction(signal_dvbt, os_type, os_value, co_value, fs, SNR, distance)

%This function calculates precise value of only standard deviation for an
%preciselly calculated SNR

    iters = 50;

    %Prędkość propagacji sygnału
    c = 299792458;
    
    %skrócenie sygnału do 2ms
    sig_time_new = numel(signal_dvbt)/50;
    
    signal = signal_dvbt(int64(numel(signal_dvbt)/3):int64(numel(signal_dvbt)/3 + sig_time_new - 1));
    
    %przesunięcie sygnałów
    delay = distance/c; %opóźnienie w s
    
    delay_samples = delay*double(fs); %opóźnienie w próbkach
    
    signal2 = [zeros(1, round(delay_samples)), signal];
    signal = [signal, zeros(1, round(delay_samples))];

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
            signal = resample(signal, double(os_value), 1);
            signal2 = resample(signal2, double(os_value), 1);
        otherwise
            os_value = 1;
    end
    fs = fs * os_value;

    est_errors = zeros(1, iters);

    for i = 1:iters
    
        noise1 = (randn(1, numel(signal)) + 1i*randn(1, numel(signal)));
        noise2 = (randn(1, numel(signal2)) + 1i*randn(1, numel(signal2)));

        check1 = snr(signal, noise1);

        signaln = signal.*db2mag(-(check1-SNR));
        signal2n = signal2.*db2mag(-(check1-SNR));
        
        signaln = signaln + noise1;
        signal2n = signal2n + noise2;
        
        %korelacja
        [corrval, lag] = xcorr(signaln, signal2n);

        if co_value == 1
            max_lag = -lag(corrval == max(corrval));
        else
            %nadpróbkowanie korelacji
            rangecorr = min(lag):(1/co_value):max(lag);
            corrval_itp = interp1(lag, corrval, rangecorr, 'spline');

%                     [max_corr, max_idx] = max(corrval_itp);
            max_lag = -rangecorr(corrval_itp == max(corrval_itp));
        end
        
        est_delay = double(max_lag)/(double(fs)); % wyestymowane opóźnienie w s
        
        est_errors(i) = abs(delay - est_delay); %błąd estymaty w sekundach
    end
    
    devs = std(est_errors);

end