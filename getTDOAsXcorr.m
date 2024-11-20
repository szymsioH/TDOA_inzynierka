function TDOAs = getTDOAsXcorr(duration, delays, fs, signal, SNRdB)

    %niedokładności wynikające z częstotliwości próbkowania
    errors_fs = 1/double(fs);
    r_errors_fs = (rand(1, 4) - 0.5)*errors_fs;

    %-NADPRÓBKOWANIE---------------------------------------------
    os_value = 10; % wartość ile razy zwiększam ilość próbek
    fs = fs * os_value;
    %powielenie próbek sygnału
%     signal = repelem(signal, os_value);
    %interpolacja liniowa
    range = 1:(1/os_value):numel(signal);
    signal = interp1(signal, range);
    %interpolacja fourierowska
%     signal = interpft(signal, os_value*numel(signal));
    %zwiększenie liczby próbek z dopasowaniem filtra dolnoprzepustowego
%     signal = resample(signal, os_value, 1);

%     numel(zeros(1, (int64(round(delays(1), strlength(int2str(fs))-1 )*fs)) ))
%     numel(zeros(1, (int64(round(delays(1) + r_errors_fs(1), strlength(int2str(fs))-1 )*fs)) ))
%     numel(zeros(1, (int64(round(delays(1) + r_errors_fs(2), strlength(int2str(fs))-1 )*fs)) ))
%     numel(zeros(1, (int64(round(delays(1) + r_errors_fs(3), strlength(int2str(fs))-1 )*fs)) ))
%     numel(zeros(1, (int64(round(delays(1) + r_errors_fs(4), strlength(int2str(fs))-1 )*fs)) ))
    %------------------------------------------------------------

    SNR = 10^(SNRdB/10);
    numSamples = duration * fs;

    noiseExample = (randn(1, numSamples) + 1i * randn(1, numSamples));
    absSignal = abs(real(signal));
    sigMean = mean(absSignal);
    absnoiseExample = abs(real(noiseExample));
    noiseMean = mean(absnoiseExample);

    sigReductionVal = (SNR*noiseMean)/sigMean;

%     figure;
%     plot(real(absNoiseO))
    %------------------------------------------------------------
    %przesunięcie sygnału
    sigOblot = [zeros(1, (int64(round(delays(1), strlength(int2str(fs))-1 )*fs)) ), zeros(1, (int64(round(r_errors_fs(1), strlength(int2str(fs))-1 )*fs)) ) ,signal];
    sigWieza = [zeros(1, (int64(round(delays(2), strlength(int2str(fs))-1 )*fs)) ), zeros(1, (int64(round(r_errors_fs(2), strlength(int2str(fs))-1 )*fs)) ) ,signal];
    sigInternat = [zeros(1, (int64(round(delays(3), strlength(int2str(fs))-1 )*fs)) ), zeros(1, (int64(round(r_errors_fs(3), strlength(int2str(fs))-1 )*fs)) ) ,signal];
    sigSzpital = [zeros(1, (int64(round(delays(4), strlength(int2str(fs))-1 )*fs)) ), zeros(1, (int64(round(r_errors_fs(4), strlength(int2str(fs))-1 )*fs)) ) ,signal];

%     sigOblot = [zeros(1, (int64(round(delays(1), strlength(int2str(fs))-1 )*fs)) ), signal2d, zeros(1, numSamples-(length(signal) + int64(round(delays(1), strlength(int2str(fs))-1 )*fs)))];
%     sigWieza = [zeros(1, (int64(round(delays(2), strlength(int2str(fs))-1 )*fs)) ), signal2d, zeros(1, numSamples-(length(signal) + int64(round(delays(2), strlength(int2str(fs))-1 )*fs)))];
%     sigInternat = [zeros(1, (int64(round(delays(3), strlength(int2str(fs))-1 )*fs)) ), signal2d, zeros(1, numSamples-(length(signal) + int64(round(delays(3), strlength(int2str(fs))-1 )*fs)))];
%     sigSzpital = [zeros(1, (int64(round(delays(4), strlength(int2str(fs))-1 )*fs)) ), signal2d, zeros(1, numSamples-(length(signal) + int64(round(delays(4), strlength(int2str(fs))-1 )*fs)))];
    
%     figure('Name', 'Oblot Signal (no noise)');
%     plot(real(sigOblot))
    %------------------------------------------------------------

    %     Tworzenie sygnału zespolonego
    noiseO = (randn(1, numel(sigOblot)) + 1i * randn(1, numel(sigOblot)))/sigReductionVal;
    noiseW = (randn(1, numel(sigWieza)) + 1i * randn(1, numel(sigWieza)))/sigReductionVal;
    noiseI = (randn(1, numel(sigInternat)) + 1i * randn(1, numel(sigInternat)))/sigReductionVal;
    noiseS = (randn(1, numel(sigSzpital)) + 1i * randn(1, numel(sigSzpital)))/sigReductionVal;

%     absNoiseO = abs(real(noiseO));
%     noiseMean2 = mean(absNoiseO);

%     figure('Name', 'Noise');
%     plot(real(noiseO))

%     SNRreal = 10*log10(sigMean/noiseMean2);

    %dodanie szumu do sygnału
    sigOblot = sigOblot + noiseO;
    sigWieza = sigWieza + noiseW;
    sigInternat = sigInternat + noiseI;
    sigSzpital = sigSzpital + noiseS;

%      figure('Name', 'Oblot Signal (added noise)');
%      plot(real(sigOblot))
%     figure;
%     plot(real(sigWieza))
%     figure;
%     plot(real(sigInternat))
%     figure;
%     plot(real(sigSzpital))

    
    %wycięcie 2ms fragmętu sygnału

    % Przy sygnale 150ms, 1 ms odpowiada 12800 próbkom, 4 ms odpowiada
    % 51200 próbkom
    size(sigOblot, 2);

    short_part = numel(sigOblot)/75;

    sigOblot = sigOblot(round(numSamples/3):round(numSamples/3) + short_part - 1);
    sigWieza = sigWieza(round(numSamples/3):round(numSamples/3) + short_part - 1);
    sigInternat = sigInternat(round(numSamples/3):round(numSamples/3) + short_part - 1);
    sigSzpital = sigSzpital(round(numSamples/3):round(numSamples/3) + short_part - 1);

%     sigOblot = sigOblot(640000:691200);
%     sigWieza = sigWieza(640000:691200);
%     sigInternat = sigInternat(640000:691200);
%     sigSzpital = sigSzpital(640000:691200);

%      figure('Name', 'Oblot Signal (added noise)');
%      plot(real(sigOblot))

    %------------------------------------------------------------
    % corrval - wartość korelacji; 
    % lag - wartość opóźnienia w którym występuje dana wartość korelacji 
    [corrval12, lag12] = (xcorr(sigOblot, sigWieza));
    [corrval13, lag13] = (xcorr(sigOblot, sigInternat));
    [corrval14, lag14] = (xcorr(sigOblot, sigSzpital));
    
    % znalezienie TDOA, czyli miejsca z największą wartością korelacji,
    % oraz przeliczenie tej wartości na czas
    TDOA12 = double(-lag12(corrval12==max(corrval12)))/double(fs);
    TDOA13 = double(-lag13(corrval13==max(corrval13)))/double(fs);
    TDOA14 = double(-lag14(corrval14==max(corrval14)))/double(fs);
    
    TDOAs = [TDOA12, TDOA13, TDOA14];
end

