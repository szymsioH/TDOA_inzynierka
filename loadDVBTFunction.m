function [signal_dvbt, fs, fc] = loadDVBTFunction(file_name)
    % file_name - string z nazwą pliku do wczytania
    % dvbt_data - struktura zawierająca dane z pliku

    if exist(file_name, 'file') ~= 2
        error('Plik %s nie istnieje.', file_name);
    end

    dvbt_data = load(file_name);

    %x - spróbkowany sygnał
    %fs - częstotliwość próbkowania
    %fc - częstotliwość nośnej

    signal_dvbt = transpose(dvbt_data.x);
    fs = int64(dvbt_data.fs);
    fc = dvbt_data.fc;

end
