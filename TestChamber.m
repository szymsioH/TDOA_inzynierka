clear workspace;

tic

distance = 10000; %odległość w m
os_type = 0; %rodzaj interpolacji/nadpróbkowania sygnału
os_value = 1;
co_value = 1;
is_synchro = 0; %0 - brak, 1 - błędy synchroniazcji
iters = 50; %iteracje
% SNR_list = [-30:2:-24, -23.5:0.5:0, 1:2:10, 10:5:160];
SNR_list = [0:5:160];

[allerr_list, SNRs_list, type_name, corr_osval] = getErrsToSnrs(distance, SNR_list, os_type, os_value, co_value, is_synchro, iters);
[allerr_list2, SNRs_list2, type_name2, corr_osval2] = getErrsToSnrs(distance, SNR_list, os_type, os_value, 10, is_synchro, iters);
[allerr_list3, SNRs_list3, type_name3, corr_osval3] = getErrsToSnrs(distance, SNR_list, os_type, os_value, 20, is_synchro, iters);
[allerr_list4, SNRs_list4, type_name4, corr_osval4] = getErrsToSnrs(distance, SNR_list, os_type, os_value, 50, is_synchro, iters);
%[allerr_list5, SNRs_list5, type_name5, corr_osval5] = getErrsToSnrs(distance, SNR_list, os_type, 50, co_value, iters);


figure('Name', 'Mean Error to SNR');
p1 = plot(SNRs_list, allerr_list(1, :)*10^(9), 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5); 
hold on;
p2 = plot(SNRs_list, allerr_list2(1, :)*10^(9), 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5);
p3 = plot(SNRs_list, allerr_list3(1, :)*10^(9), 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 1.5);
p4 = plot(SNRs_list, allerr_list4(1, :)*10^(9), 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5);
%p5 = plot(SNRs_list, allerr_list5(1, :)*10^(9), 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 1.5);
title([num2str(distance), 'm, ', num2str(os_value), '*fs, ', num2str(iters),  'iteracji, ', type_name, corr_osval])
xlabel('SNR [dB]')
ylabel('Średnia wartość błędu [ns]')
legend([p1, p2, p3, p4], {'no os', '5', '10', '20'}, 'Location', 'best')
grid on

figure('Name', 'Deviations to SNR');
p1 = plot(SNRs_list, allerr_list(2, :)*10^(9), 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5); 
hold on;
p2 = plot(SNRs_list, allerr_list2(2, :)*10^(9), 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5);
p3 = plot(SNRs_list, allerr_list3(2, :)*10^(9), 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 1.5);
p4 = plot(SNRs_list, allerr_list4(2, :)*10^(9), 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5);
%p5 = plot(SNRs_list, allerr_list5(2, :)*10^(9), 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 1.5);
title([num2str(distance), 'm, ', num2str(os_value), '*fs, ', num2str(iters),  'iteracji, ', type_name, corr_osval])
xlabel('SNR [dB]')
ylabel('Odchylenie standardowe [ns]')
legend([p1, p2, p3, p4], {'no os', '5', '10', '20'}, 'Location', 'best')
grid on

figure('Name', 'RMS to SNR');
p1 = plot(SNRs_list, allerr_list(3, :)*10^(9), 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5); 
hold on;
p2 = plot(SNRs_list, allerr_list2(3, :)*10^(9), 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5);
p3 = plot(SNRs_list, allerr_list3(3, :)*10^(9), 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 1.5);
p4 = plot(SNRs_list, allerr_list4(3, :)*10^(9), 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5);
%p5 = plot(SNRs_list, allerr_list5(3, :)*10^(9), 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 1.5);
title([num2str(distance), 'm, ', num2str(os_value), '*fs, ', num2str(iters),  'iteracji, ', type_name, corr_osval])
xlabel('SNR [dB]')
ylabel('RMS [ns]')
legend([p1, p2, p3, p4], {'no os', '5', '10', '20'}, 'Location', 'best')
grid on


toc