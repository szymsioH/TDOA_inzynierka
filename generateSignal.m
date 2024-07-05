function signal = generateSignal(duration, fs)
    % Parametry wejściowe:
    %   duration - czas trwania sygnału w sekundach
    %   fs - częstotliwość próbkowania w Hz
    % Parametry wyjściowe:
    %   signal - struktura zawierająca sygnał i wektor czasu

    % Obliczanie liczby próbek
    numSamples = duration * fs;

    % Generowanie wektora czasu
    sigTime = (0:numSamples-1)/fs;

    % Tworzenie sygnału zespolonego
    signal = randn(1, numSamples) + 1i * randn(1, numSamples);

end