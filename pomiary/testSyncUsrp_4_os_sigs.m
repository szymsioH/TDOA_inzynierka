% clear all;
% close all;
% 
% tic
% 
% folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary';
% cd(folder);
% 
% % files1 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary\0\15-28-02\*.usf');
% % files2 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary\7\15-28-02\*.usf');
% 
% files1 = dir('D:\pomiary_lab_inz\0\15-28-02\*.usf');
% files2 = dir('D:\pomiary_lab_inz\7\15-28-02\*.usf');
% 
% for k = 1:12
%     [header1, data1] = USF.readUSFFile([files1(1).folder filesep files1(k).name]);
%     [header2, data2] = USF.readUSFFile([files2(1).folder filesep files2(k).name]);
%     eval(['header1_' num2str(k) ' = header1;']);
%     eval(['data1_' num2str(k) ' = data1;']);
%     eval(['header2_' num2str(k) ' = header2;']);
%     eval(['data2_' num2str(k) ' = data2;']);
% end
% 
% % data1 = double(data1);
% % data2 = double(data2);
% 
% %[x, d] = (xcorr(data1, data2, 50, 'normalized')); %50 to ilość próbek wziętych pod uwagę w korelacji
% 
% iter = 100;
% impulse_len = 20000; %20000 = 2ms
% os_value = 10;
% co_value = 5;
% 
% 
% d_maxes = zeros(1, iter);
% d_maxes_os = zeros(1, iter);
% 
% for p = 1:iter
%     p;
%     rand_file = randi([1, 12]);
% 
%     eval(['data1 = ' 'data1_' num2str(rand_file) ';']);
%     eval(['data2 = ' 'data2_' num2str(rand_file) ';']);
% 
%     data1 = double(data1);
%     data2 = double(data2);
%     
%     if impulse_len <= 9500000
%         rand_part = randi([1, (numel(data1))-(impulse_len+1)]);
%     else
%         rand_part  = 1;
%     end
% 
%     [x, d] = (xcorr(data1(rand_part:rand_part+impulse_len-1), data2(rand_part:rand_part+impulse_len-1), 50, 'normalized'));
%     
%     max_d = d(max(x)==x);
%     d_maxes(p) = max_d;
% 
%     data_before1 = data1(rand_part:rand_part+impulse_len-1);
%     data_before2 = data2(rand_part:rand_part+impulse_len-1);
% 
%     data1_osd1 = interpft(data_before1, os_value*numel(data_before1)); 
%     data2_osd1 = interpft(data_before2, os_value*numel(data_before2)); 
% 
%     [x1, d1] = (xcorr(data1_osd1, data2_osd1, 50*os_value, 'normalized'));
% 
% %     d1 = d1/os_value;
%     
%     max_d = d1(x1 == max(x1))/os_value;
%     
%     %max_d = d(max(x)==x);
%     d_maxes_os(p) = max_d;
% 
% end

figure
plot(d, db(x))
title('Wykres korelacji, sygnał 100 us')
xlabel('Wartości opóźnień (w próbkach)')
ylabel('Poziom korelacji [dB]')


figure
plot(d1/os_value, db(x1))
title('Wykres korelacji, sygnał 100 us (nadpróbkowanie syg. 5))')
xlabel('Wartości opóźnień (w próbkach)')
ylabel('Poziom korelacji [dB]')

% figure
% plot(d2, x2)

figure;
h1 = histogram(d_maxes, double(min(d_maxes))-2.5:1:double(max(d_maxes))+2.5);
title(['Moc -100 dBm, ', 'długość 100 us, ', '100 iteracji'])
xlabel('Wartości opóźnień (w próbkach)')
ylabel('Liczba powtórzeń wyniku')
hold on
l1 = xline(1, '-r', 'LineWidth', 1.5);
grid on
legend([h1, l1], {'Wartości opóźnień', 'Rzeczywista wartość opóźnienia'}, 'Location','northwest')

figure;
h1 = histogram(d_maxes_os, double(min(d_maxes))-2.5:1:double(max(d_maxes))+2.5);
title(['Moc -100 dBm, ', 'długość 100 us, ', '100 iteracji, ', 'nadpróbkowanie syg. 5'])
xlabel('Wartości opóźnień (w próbkach)')
ylabel('Liczba powtórzeń wyniku')
hold on
l1 = xline(1, '-r', 'LineWidth', 1.5);
grid on
legend([h1, l1], {'Wartości opóźnień', 'Rzeczywista wartość opóźnienia'}, 'Location','northwest')

figure;
h1 = histogram(d_maxes_os, double(min(d_maxes))-2.5:1/os_value:double(max(d_maxes))+2.5);
title(['Moc -100 dBm, ', 'długość 100 us, ', '100 iteracji, ', 'nadpróbkowanie syg. 5 '])
xlabel('Wartości opóźnień (w próbkach)')
ylabel('Liczba powtórzeń wyniku')
hold on
l1 = xline(1, '-r', 'LineWidth', 1.5);
grid on
legend([h1, l1], {'Wartości opóźnień', 'Rzeczywista wartość opóźnienia'}, 'Location','northwest')

% figure;
% h1 = histogram(d_maxes_os2, double(min(d_maxes))-2.5:1:double(max(d_maxes))+2.5);
% title(['Moc -100 dBm, ', 'długość 2 ms, ', '100 iteracji, ', 'nadpróbkowanie syg. 10'])
% xlabel('Wartości opóźnień (w próbkach)')
% ylabel('Liczba powtórzeń wyniku')
% hold on
% l1 = xline(1, '-r', 'LineWidth', 1.5);
% grid on
% legend([h1, l1], {'Wartości opóźnień', 'Rzeczywista wartość opóźnienia'}, 'Location','northwest')




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