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

iter = 50;
impulse_len = 20000; %20000 = 2ms
os_value = 5;
os_value2 = 10;

%len_list = [100000, 50000, 10000, 8000, 5000, 2000, 1000];

std_iters = 1:30;

stds1 = zeros(1, numel(std_iters));
stds2 = zeros(1, numel(std_iters));
stds3 = zeros(1, numel(std_iters));
stds4 = zeros(1, numel(std_iters));
mean1 = zeros(1, numel(std_iters));
mean2 = zeros(1, numel(std_iters));
mean3 = zeros(1, numel(std_iters));
mean4 = zeros(1, numel(std_iters));
rmss1 = zeros(1, numel(std_iters));
rmss2 = zeros(1, numel(std_iters));
rmss3 = zeros(1, numel(std_iters));
rmss4 = zeros(1, numel(std_iters));

flag_temp = 0;

for h = std_iters
    flag_temp = flag_temp + 1;
    d_maxes = zeros(1, iter);
    d_maxes_os1 = zeros(1, iter);
    d_maxes_os2 = zeros(1, iter);
    d_maxes_os3 = zeros(1, iter);
    d_maxes_os4 = zeros(1, iter);
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

%         rangecorr = min(d):(1/co_value):max(d);
%         corrval_itp = interp1(d, x, rangecorr, 'spline');
%         max_d = rangecorr(corrval_itp == max(corrval_itp));
%         d_maxes_os1(p) = max_d;
% 
%         rangecorr2 = min(d):(1/co_value2):max(d);
%         corrval_itp2 = interp1(d, x, rangecorr2, 'spline');
%         max_d = rangecorr2(corrval_itp2 == max(corrval_itp2));
%         d_maxes_os2(p) = max_d;
    
        data_before1 = data1(rand_part:rand_part+impulse_len-1);
        data_before2 = data2(rand_part:rand_part+impulse_len-1);
    
        data1_osd1 = interpft(data_before1, os_value*numel(data_before1)); 
        data2_osd1 = interpft(data_before2, os_value*numel(data_before2)); 
    
        [x1, d1] = (xcorr(data1_osd1, data2_osd1, 50*os_value, 'normalized'));
        
        max_d = d1(max(x1)==x1)/os_value;
        d_maxes_os1(p) = max_d;

%         data1_osd2 = interpft(data_before1, os_value2*numel(data_before1)); 
%         data2_osd2 = interpft(data_before2, os_value2*numel(data_before2)); 
%     
%         [x2, d2] = (xcorr(data1_osd2, data2_osd2, 50*os_value2, 'normalized'));
%         
%         max_d = d2(max(x2)==x2)/os_value2;
%         d_maxes_os2(p) = max_d;
   
        data1_osd2 = interp1(data_before1, 1:1/os_value:numel(data_before1)); 
        data2_osd2 = interp1(data_before2, 1:1/os_value:numel(data_before2)); 
    
        [x2, d2] = (xcorr(data1_osd2, data2_osd2, 50*os_value, 'normalized'));
        
        max_d = d2(max(x2)==x2)/os_value;
        d_maxes_os2(p) = max_d;
    
        data1_osd3 = repelem(data_before1, os_value); 
        data2_osd3 = repelem(data_before2, os_value); 
    
        [x3, d3] = (xcorr(data1_osd3, data2_osd3, 50, 'normalized'));
        
        max_d = d3(max(x3)==x3)/os_value;
        d_maxes_os3(p) = max_d;
    
        data1_osd4 = resample(data_before1, os_value, 1); 
        data2_osd4 = resample(data_before2, os_value, 1); 
    
        [x4, d4] = (xcorr(data1_osd4, data2_osd4, 50*os_value, 'normalized'));
        
        max_d = d4(max(x4)==x4)/os_value;
        d_maxes_os4(p) = max_d;
    end
    stds0(flag_temp) = std(d_maxes);
    stds1(flag_temp) = std(d_maxes_os1);
    stds2(flag_temp) = std(d_maxes_os2);
    stds3(flag_temp) = std(d_maxes_os3);
    stds4(flag_temp) = std(d_maxes_os4);
    mean0(flag_temp) = mean(d_maxes);
    mean1(flag_temp) = mean(d_maxes_os1);
    mean2(flag_temp) = mean(d_maxes_os2); 
    mean3(flag_temp) = mean(d_maxes_os3);
    mean4(flag_temp) = mean(d_maxes_os4);
    rmss0(flag_temp) = rms(d_maxes);
    rmss1(flag_temp) = rms(d_maxes_os1);
    rmss2(flag_temp) = rms(d_maxes_os2); 
    rmss3(flag_temp) = rms(d_maxes_os3);
    rmss4(flag_temp) = rms(d_maxes_os4); 
%     stds4(flag_temp) = std(d_maxes_os4);
end



% figure;
% h1 = histogram(d_maxes, double(min(d_maxes))-2.5:1:double(max(d_maxes))+2.5);
% title(['Moc -100 dBm, ', 'długość 2 ms, ', '100 iteracji'])
% xlabel('Wartości opóźnień (w próbkach)')
% ylabel('Liczba powtórzeń wyniku')
% hold on
% l1 = xline(1, '-r', 'LineWidth', 1.5);
% grid on
% legend([h1, l1], {'Wartości opóźnień', 'Rzeczywista wartość opóźnienia'}, 'Location','northwest')
% 
% figure;
% h1 = histogram(d_maxes_os4, double(min(d_maxes))-2.5:1:double(max(d_maxes))+2.5);
% title(['Moc -100 dBm, ', 'długość 2 ms, ', '100 iteracji, ', 'nadpróbkowanie syg. 5'])
% xlabel('Wartości opóźnień (w próbkach)')
% ylabel('Liczba powtórzeń wyniku')
% hold on
% l1 = xline(1, '-r', 'LineWidth', 1.5);
% grid on
% legend([h1, l1], {'Wartości opóźnień', 'Rzeczywista wartość opóźnienia'}, 'Location','northwest')

% figure;
% h1 = histogram(d_maxes_os2, double(min(d_maxes))-2.5:1:double(max(d_maxes))+2.5);
% title(['Moc -100 dBm, ', 'długość 2 ms, ', '100 iteracji, ', 'nadpróbkowanie kor. 10'])
% xlabel('Wartości opóźnień (w próbkach)')
% ylabel('Liczba powtórzeń wyniku')
% hold on
% l1 = xline(1, '-r', 'LineWidth', 1.5);
% grid on
% legend([h1, l1], {'Wartości opóźnień', 'Rzeczywista wartość opóźnienia'}, 'Location','northwest')

figure;
s1 = plot(std_iters, stds1, 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5);
hold on
s2 = plot(std_iters, stds2, 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 1.5);
s3 = plot(std_iters, stds3, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5);
s4 = plot(std_iters, stds4, 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 1.5);
title(['Moc -100 dBm, ', 'długość 2 ms, ', '50 iteracji, (nadpróbkowanie korelacji)'])
xlabel('Iteracja programu')
ylabel('Odchylenie standardowe pomiarów (w próbkach)')
legend([s1, s2, s3, s4], {'interpfr', 'interp1', 'repelem', 'resample'}, 'Location', 'best')
grid on


figure;
s1 = plot(std_iters, mean1, 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5);
hold on
s2 = plot(std_iters, mean2, 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 1.5);
s3 = plot(std_iters, mean3, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5);
s4 = plot(std_iters, mean4, 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 1.5);
l1 = yline(1, '--b', 'LineWidth', 0.8);
title(['Moc -100 dBm, ', 'długość 2 ms, ', '50 iteracji, '])
xlabel('Iteracja programu')
ylabel('Średnia wartość estymacji (w próbkach)')
legend([s1, s2, s3, s4, l1], {'interpfr', 'interp1', 'repelem', 'resample', 'op. rzeczywiste'}, 'Location', 'best')
grid on

figure;
s1 = plot(std_iters, rmss1, 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5);
hold on
s2 = plot(std_iters, rmss2, 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 1.5);
s3 = plot(std_iters, rmss3, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5);
s4 = plot(std_iters, rmss4, 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 1.5);
title(['Moc -100 dBm, ', 'długość 2 ms, ', '50 iteracji, '])
xlabel('Iteracja programu')
ylabel('RMS (w próbkach)')
legend([s1, s2, s3, s4], {'interpfr', 'interp1', 'repelem', 'resample'}, 'Location', 'best')
grid on

% [x, d] = (xcorr(data1, data2, 50, 'normalized'));
% rangecorr = min(d):(1/co_value):max(d);
% corrval_itp = interp1(d, x, rangecorr, 'spline');
% 
% figure('Name', 'Korelacja')
% plot(rangecorr, db(corrval_itp))
% title(['Korelacja dla sygnału o mocy ', '-100', ' dBm'])
% xlabel('Opóźnienie (w próbkach)')
% ylabel('Moc [dBm]')




toc