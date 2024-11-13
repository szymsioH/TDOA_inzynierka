function TDOAs = getTDOAsXcorr(duration, delays, fs, signal, SNRdB)

%     noise = generateNoise(duration, fs);
    
    %------------------------------------------------------------
    % SYGNAŁ TESTOWY (SINC)
%     t1 = linspace(-3, 3, 10^1);
%     signal2 = sinc(t1);
%     signal = signal2*30;
%     signal = [zeros(1, 2*10^6), signal, zeros(1, 5*10^5), signal, zeros(1, 4*10^5), signal, zeros(1, 4*10^5), signal, zeros(1, 1*10^6), signal, zeros(1, 1*10^6), signal];
%     signal2d = signal + 1i*signal;

%     %noise
%     % Obliczanie liczby próbek

    SNR = 10^(SNRdB/10);

    numSamples = duration * fs;

    noiseExample = (randn(1, numSamples) + 1i * randn(1, numSamples));

    absSignal = abs(real(signal));
    sigMean = mean(absSignal);

    absnoiseExample = abs(real(noiseExample));
    noiseMean = mean(absnoiseExample);

    sigReductionVal = (SNR*noiseMean)/sigMean;

%     Tworzenie sygnału zespolonego
    noiseO = (randn(1, numSamples) + 1i * randn(1, numSamples))/sigReductionVal;
    noiseW = (randn(1, numSamples) + 1i * randn(1, numSamples))/sigReductionVal;
    noiseI = (randn(1, numSamples) + 1i * randn(1, numSamples))/sigReductionVal;
    noiseS = (randn(1, numSamples) + 1i * randn(1, numSamples))/sigReductionVal;

    absNoiseO = abs(real(noiseO));
    noiseMean2 = mean(absNoiseO);

%     figure('Name', 'Noise');
%     plot(real(noiseO))

    SNRreal = 10*log10(sigMean/noiseMean2);
%     figure;
%     plot(real(absNoiseO))
    %------------------------------------------------------------
    %przesunięcie sygnału
    sigOblot = [zeros(1, (int64(round(delays(1), strlength(int2str(fs))-1 )*fs)) ), signal, zeros(1, numSamples-(length(signal) + int64(round(delays(1), strlength(int2str(fs))-1 )*fs)))];
    sigWieza = [zeros(1, (int64(round(delays(2), strlength(int2str(fs))-1 )*fs)) ), signal, zeros(1, numSamples-(length(signal) + int64(round(delays(2), strlength(int2str(fs))-1 )*fs)))];
    sigInternat = [zeros(1, (int64(round(delays(3), strlength(int2str(fs))-1 )*fs)) ), signal, zeros(1, numSamples-(length(signal) + int64(round(delays(3), strlength(int2str(fs))-1 )*fs)))];
    sigSzpital = [zeros(1, (int64(round(delays(4), strlength(int2str(fs))-1 )*fs)) ), signal, zeros(1, numSamples-(length(signal) + int64(round(delays(4), strlength(int2str(fs))-1 )*fs)))];

%     sigOblot = [zeros(1, (int64(round(delays(1), strlength(int2str(fs))-1 )*fs)) ), signal2d, zeros(1, numSamples-(length(signal) + int64(round(delays(1), strlength(int2str(fs))-1 )*fs)))];
%     sigWieza = [zeros(1, (int64(round(delays(2), strlength(int2str(fs))-1 )*fs)) ), signal2d, zeros(1, numSamples-(length(signal) + int64(round(delays(2), strlength(int2str(fs))-1 )*fs)))];
%     sigInternat = [zeros(1, (int64(round(delays(3), strlength(int2str(fs))-1 )*fs)) ), signal2d, zeros(1, numSamples-(length(signal) + int64(round(delays(3), strlength(int2str(fs))-1 )*fs)))];
%     sigSzpital = [zeros(1, (int64(round(delays(4), strlength(int2str(fs))-1 )*fs)) ), signal2d, zeros(1, numSamples-(length(signal) + int64(round(delays(4), strlength(int2str(fs))-1 )*fs)))];
    
%     figure('Name', 'Oblot Signal (no noise)');
%     plot(real(sigOblot))
    %------------------------------------------------------------
    %dodanie szumu do sygnału
    sigOblot = sigOblot + noiseO;
    sigWieza = sigWieza + noiseW;
    sigInternat = sigInternat + noiseI;
    sigSzpital = sigSzpital + noiseS;

%      figure;
%      plot(real(sigOblot))
%     figure;
%     plot(real(sigWieza))
%     figure;
%     plot(real(sigInternat))
%     figure;
%     plot(real(sigSzpital))

    
    %wycięcie 4ms fragmętu sygnału

    % Przy sygnale 150ms, 1 ms odpowiada 12800 próbkom, 4 ms odpowiada
    % 51200 próbkom
    size(sigOblot, 2);

    sigOblot = sigOblot(640000:691200);
    sigWieza = sigWieza(640000:691200);
    sigInternat = sigInternat(640000:691200);
    sigSzpital = sigSzpital(640000:691200);

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

