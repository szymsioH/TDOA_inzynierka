clear all;
close all;

tic

folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary';
cd(folder);

% files1 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary\0\15-28-02\*.usf');
% files2 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary\7\15-28-02\*.usf');

files1 = dir('D:\pomiary_lab_inz\0\15-28-02\*.usf');
files2 = dir('D:\pomiary_lab_inz\7\15-28-02\*.usf');

for k = 1:12
    [header1, data1] = USF.readUSFFile([files1(1).folder filesep files1(k).name]);
    [header2, data2] = USF.readUSFFile([files2(1).folder filesep files2(k).name]);
    eval(['header1_' num2str(k) ' = header1;']);
    eval(['data1_' num2str(k) ' = data1;']);
    eval(['header2_' num2str(k) ' = header2;']);
    eval(['data2_' num2str(k) ' = data2;']);
end

% data1 = double(data1);
% data2 = double(data2);

%[x, d] = (xcorr(data1, data2, 50, 'normalized')); %50 to ilość próbek wziętych pod uwagę w korelacji

iter = 100;
impulse_len = 1000; %20000 = 2ms
co_value = 5;
co_value2 = 10;


d_maxes = zeros(1, iter);
d_maxes_os = zeros(1, iter);
d_maxes_os2 = zeros(1, iter);

for p = 1:iter
    p;
    rand_file = randi([1, 12]);

    eval(['data1 = ' 'data1_' num2str(rand_file) ';']);
    eval(['data2 = ' 'data2_' num2str(rand_file) ';']);

    data1 = double(data1);
    data2 = double(data2);
    
    if impulse_len <= 9500000
        rand_part = randi([1, (numel(data1))-(impulse_len+1)]);
    else
        rand_part  = 1;
    end

    [x, d] = (xcorr(data1(rand_part:rand_part+impulse_len-1), data2(rand_part:rand_part+impulse_len-1), 50, 'normalized'));
    
    max_d = d(max(x)==x);
    d_maxes(p) = max_d;

    rangecorr = min(d):(1/co_value):max(d);
    corrval_itp = interp1(d, x, rangecorr, 'spline');
    max_d = rangecorr(corrval_itp == max(corrval_itp));
    
    %max_d = d(max(x)==x);
    d_maxes_os(p) = max_d;

    rangecorr = min(d):(1/co_value2):max(d);
    corrval_itp = interp1(d, x, rangecorr, 'spline');
    max_d = rangecorr(corrval_itp == max(corrval_itp));
    
    d_maxes_os2(p) = max_d;
end



figure;
h1 = histogram(d_maxes, double(min(d_maxes))-2.5:1:double(max(d_maxes))+2.5);
title(['Moc -100 dBm, ', 'długość 2 ms, ', '100 iteracji'])
xlabel('Wartości opóźnień (w próbkach)')
ylabel('Liczba powtórzeń wyniku')
xlim([-10 5])
hold on
l1 = xline(1, '-r', 'LineWidth', 1.5);
grid on
legend([h1, l1], {'Wartości opóźnień', 'Rzeczywista wartość opóźnienia'}, 'Location','northwest')

% figure
% h1 = histogram(d_maxes_os, double(min(d_maxes))-2.5:1:double(max(d_maxes))+2.5);
% title(['Moc -100 dBm, ', 'długość 2 ms, ', '100 iteracji, nadpróbkowanie kor. 5'])
% xlabel('Wartości opóźnień (w próbkach)')
% ylabel('Liczba powtórzeń wyniku')
% % xlim([-15 10])
% hold on
% l1 = xline(1, '-r', 'LineWidth', 1.5);
% grid on
% legend([h1, l1], {'Wartości opóźnień', 'Rzeczywista wartość opóźnienia'}, 'Location','northwest')

figure;
h1 = histogram(d_maxes_os, double(min(d_maxes))-2.5:1/co_value:double(max(d_maxes))+2.5);
title(['Moc -100 dBm, ', 'długość 2 ms, ', '100 iteracji, ', 'nadpróbkowanie kor. 5'])
xlabel('Wartości opóźnień (w próbkach)')
ylabel('Liczba powtórzeń wyniku')
xlim([-10 5])
hold on
l1 = xline(1, '-r', 'LineWidth', 1.5);
grid on
legend([h1, l1], {'Wartości opóźnień', 'Rzeczywista wartość opóźnienia'}, 'Location','northwest')

figure;
h1 = histogram(d_maxes_os2, double(min(d_maxes))-2.5:1/co_value2:double(max(d_maxes))+2.5);
title(['Moc -100 dBm, ', 'długość 2 ms, ', '100 iteracji, ', 'nadpróbkowanie kor. 10'])
xlabel('Wartości opóźnień (w próbkach)')
ylabel('Liczba powtórzeń wyniku')
xlim([-10 5])
hold on
l1 = xline(1, '-r', 'LineWidth', 1.5);
grid on
legend([h1, l1], {'Wartości opóźnień', 'Rzeczywista wartość opóźnienia'}, 'Location','northwest')


% [x, d] = (xcorr(data1, data2, 50, 'normalized'));
% rangecorr = min(d):(1/co_value):max(d);
% corrval_itp = interp1(d, x, rangecorr, 'spline');
% 
% figure('Name', 'Korelacja')
% plot(rangecorr, db(corrval_itp))
% title(['Korelacja dla sygnału o mocy ', '-100', ' dBm'])
% xlabel('Opóźnienie (w próbkach)')
% ylabel('Moc [dBm]')


folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo\charts\pomiary2';
cd(folder);

toc