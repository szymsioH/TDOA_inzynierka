function est_errors = getSourcesMesh(x_car, c, fs, signal_dvbt, duration)

    wgs84 = wgs84Ellipsoid("meter");
    x0 = [0; 0; 0];
    options = optimoptions('fminunc','Algorithm','quasi-newton','Display','iter');

    sourceRange = -5000:1000:5000;

    [xsourceMesh, ysourceMesh] = meshgrid(sourceRange, sourceRange);

    est_errors = zeros(1, numel(xsourceMesh));

    est_index = 0;

%     figure('Name', 'Testing Sources Mesh Layout');
%     plot(x_car(1, 2:5), x_car(2, 2:5), '^black', 'MarkerSize', 5, 'MarkerFaceColor', 'yellow');
%     hold on
%     plot(xsourceMesh, ysourceMesh, 'r.', 'MarkerSize', 10);
%     legend('Odbiorniki', 'Nadajniki');


    for i = 1:numel(xsourceMesh)
            est_index = est_index + 1;
            sig_source = [xsourceMesh(i), ysourceMesh(i)];

            delay_oblot = calcDelayFunction(sig_source(1),sig_source(2),120,x_car(1, 2),x_car(2, 2),x_car(3, 2), c);
            delay_wieza = calcDelayFunction(sig_source(1),sig_source(2),120,x_car(1, 3),x_car(2, 3),x_car(3, 3), c);
            delay_internat = calcDelayFunction(sig_source(1),sig_source(2),120,x_car(1, 4),x_car(2, 4),x_car(3, 4), c);
            delay_szpital = calcDelayFunction(sig_source(1),sig_source(2),120,x_car(1, 5),x_car(2, 5),x_car(3, 5), c);
            delays = [delay_oblot, delay_wieza, delay_internat, delay_szpital];

            TDOAs = getTDOAsXcorr(duration, delays, fs, signal_dvbt, -3);
            [x_hat_opt, fval] = fminunc(@(x_hat) costFunctionLS_TDOA(x_hat, x_car, TDOAs, c), x0, options);
            nad_coord = [sig_source(1); sig_source(2); 120];
            est_errors(est_index) = norm(x_hat_opt(1:2) - nad_coord(1:2));
    end

    disp('Błędy siatki nadajników:');
    disp(est_errors);

    % uśrednienie wyników powyżej 100km do 100km
    for i = 1:numel(est_errors)
        if est_errors(i) >= 50000
            est_errors(i) = 50000;
        end
    end

    % Użycie transformacji logarytmicznej, aby zmniejszyć wpływ dużych wartości błędów
    est_errors_scaled = log1p(est_errors); % log1p(x) = log(1 + x), gdzie x > -1

    figure('Name', 'Sources Mesh Estimate Errors');
    scatter3(xsourceMesh(:), ysourceMesh(:), est_errors(:), 30, est_errors_scaled(:), 'filled');
    colormap(jet); % Ustawienie mapy kolorów (możesz eksperymentować np. z 'hot' lub 'parula')
    hcb = colorbar; % Dodanie paska kolorów do interpretacji

    tick_values = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, max(est_errors)];
    tick_positions = log1p(tick_values); % Pozycje znaczników po przekształceniu log1p

    set(hcb, 'Ticks', tick_positions, 'TickLabels', tick_values);

    hold on;
    plot3(x_car(1, 2:5), x_car(2, 2:5), zeros(1, 4), '^k', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');
    legend('Odbiorniki');
    
    % ustawienie osi Z
    zlim([min(est_errors), max(est_errors)]);

end

