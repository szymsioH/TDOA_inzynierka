clear all;
close all;

tic

folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary';
cd(folder);

files1 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary\0\15-20-10\*.usf');
files2 = dir('C:\Users\szymo\OneDrive\Pulpit\Inz_repo\pomiary\7\15-20-10\*.usf');

% files1 = dir('D:\pomiary_lab_inz\0\15-20-10\*.usf');
% files2 = dir('D:\pomiary_lab_inz\7\15-20-10\*.usf');
% 
% for k = 1:12
%     [header1, data1] = USF.readUSFFile([files1(1).folder filesep files1(k).name]);
%     [header2, data2] = USF.readUSFFile([files2(1).folder filesep files2(k).name]);
%     eval(['header1_' num2str(k) ' = header1;']);
%     eval(['data1_' num2str(k) ' = data1;']);
%     eval(['header2_' num2str(k) ' = header2;']);
%     eval(['data2_' num2str(k) ' = data2;']);
% end

[header1, data1] = USF.readUSFFile([files1(1).folder filesep files1(1).name]);
[header2, data2] = USF.readUSFFile([files2(1).folder filesep files2(1).name]);

data1 = double(data1);
data2 = double(data2);

[x, d] = (xcorr(data1, data2, 50, 'normalized')); %50 to ilość próbek wziętych pod uwagę w korelacji

% iter = 100;
% impulse_len = 20000; %20000 = 2ms
% 
% sigmas = zeros(1, 6);
% flag_temp = 0;
% 
% d_maxes = zeros(1, iter);
% 
% % for d = [10000000, 1000000, 100000, 10000, 1000, 100] 
% %     flag_temp = flag_temp + 1;
% %     d_maxes = zeros(1, iter);
% %     impulse_len = d;
%     for p = 1:iter
%         p;
%         rand_file = randi([1, 12]);
%     
%         eval(['data1 = ' 'data1_' num2str(rand_file) ';']);
%         eval(['data2 = ' 'data2_' num2str(rand_file) ';']);
%     
%         data1 = double(data1);
%         data2 = double(data2);
%         
%         if impulse_len <= 9500000
%             rand_part = randi([1, (numel(data1))-(impulse_len+1)]);
%         else
%             rand_part  = 1;
%         end
%     
%         [x, d] = (xcorr(data1(rand_part:rand_part+impulse_len-1), data2(rand_part:rand_part+impulse_len-1), 50, 'normalized'));
%         max_d = d(max(x)==x);
%         d_maxes(p) = max_d;
%     end
% %     sigmas(flag_temp) = std(d_maxes);
% % end
% 
% % pl_range = [10000000, 1000000, 100000, 10000, 1000, 100];
% % 
% % figure;
% % p1 = plot(pl_range, sigmas);


% figure;
% h1 = histogram(d_maxes, double(min(d_maxes))-2.5:1:double(max(d_maxes))+2.5);
% title(['Moc -100 dBm, ', 'długość 2 ms, ', '100 iteracji'])
% xlabel('Wartości opóźnień (w próbkach)')
% ylabel('Liczba powtórzeń wyniku')
% hold on
% l1 = xline(1, '-r', 'LineWidth', 1.5);
% grid on
% legend([h1, l1], {'Wartości opóźnień', 'Rzeczywista wartość opóźnienia'}, 'Location','best')
% 
% [x, d] = (xcorr(data1, data2, 50, 'normalized'));

figure('Name', 'Korelacja')
stem((d/10e+06)*1e+09, db(x)+50)
title(['Korelacja dla sygnału o mocy ', '-40', ' dBm'])
xlabel('Opóźnienie [ns]')
ylabel('Moc [dBm]')
grid on
yticks(-70:10:120)
yticklabels(-120:10:120) 
% 
% 
% f = linspace(-5, 5, length(data1));
% figure('Name', 'Widmo sygnału')
% plot(f, db(fftshift(fft(data1))))
% title(['Widmo sygnału o mocy ', '-100', ' dBm'])
% xlabel('Szerokość pasma [MHz] ')
% ylabel('Moc [dBm]')



toc