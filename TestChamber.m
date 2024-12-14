clear workspace;

tic

distance = 10000; %odległość w m
os_type = 0; %rodzaj interpolacji
os_value = 1;
co_value = 1;
iters = 1000; %iteracje

[allerr_list, SNRs_list, type_name, corr_osval] = getErrsToSnrs(distance, os_type, os_value, co_value, iters);



% [allerr_list2, SNRs_list2, type_name2, corr_osval2] = getErrsToSnrs(distance, os_type, os_value, 5, iters);
% [allerr_list3, SNRs_list3, type_name3, corr_osval3] = getErrsToSnrs(distance, os_type, os_value, 10, iters);

figure('Name', 'Mean Error to SNR');
plot(SNRs_list, allerr_list(1, :)*10^(9)); %w ns
title([num2str(distance), 'm, ', num2str(os_value), '*fs, ', num2str(iters),  'iteracji, ', type_name, corr_osval])
xlabel('SNR [dB]')
ylabel('Średnia wartość błędu [ns]')
hold on
plot(SNRs_list, allerr_list2(1, :)*10^(9), 'Color', 'magenta');
hold on
plot(SNRs_list, allerr_list3(1, :)*10^(9), 'Color', 'green');
legend('*1', '*5', '*10')

figure('Name', 'Deviations to SNR');
plot(SNRs_list, allerr_list(2, :)*10^(9)); %w ns
title([num2str(distance), 'm, ', num2str(os_value), '*fs, ', num2str(iters),  'iteracji, ', type_name, corr_osval])
xlabel('SNR [dB]')
ylabel('Odchylenie standardowe [ns]')
hold on
plot(SNRs_list, allerr_list2(2, :)*10^(9), 'Color', 'magenta');
hold on
plot(SNRs_list, allerr_list3(2, :)*10^(9), 'Color', 'green');
legend('*1', '*5', '*10')

figure('Name', 'RMS to SNR');
plot(SNRs_list, allerr_list(3, :)*10^(9)); %w ns
title([num2str(distance), 'm, ', num2str(os_value), '*fs, ', num2str(iters),  'iteracji, ', type_name, corr_osval])
xlabel('SNR [dB]')
ylabel('RMS [ns]')
hold on
plot(SNRs_list, allerr_list2(3, :)*10^(9), 'Color', 'magenta');
hold on
plot(SNRs_list, allerr_list3(3, :)*10^(9), 'Color', 'green');
legend('*1', '*5', '*10')

toc