function [mean_errors, deviations] = getSourcesMesh(x_car, c, fs, signal_dvbt, duration)

    wgs84 = wgs84Ellipsoid("meter");
    x0 = [0; 0];
    options = optimoptions('fminunc','Algorithm','quasi-newton','Display','off');

    sourceRange = -6000:1000:6000;

    [xsourceMesh, ysourceMesh] = meshgrid(sourceRange, sourceRange);

    figure('Name', 'Testing Sources Mesh Layout');
    plot(x_car(1, 2:5), x_car(2, 2:5), '^black', 'MarkerSize', 5, 'MarkerFaceColor', 'yellow');
    hold on
    plot(xsourceMesh, ysourceMesh, 'r.', 'MarkerSize', 10);
    legend('Odbiorniki', 'Nadajniki');

    iter = 20;
    mean_errors = zeros(numel(xsourceMesh(:, 1)), numel(ysourceMesh(1, :)));
    deviations = zeros(numel(xsourceMesh(:, 1)), numel(ysourceMesh(1, :)));

    for j = 1:numel(xsourceMesh)
        sqrtsum = 0;
        temp_errors_storage = zeros(iter, 1);
        sig_source = [xsourceMesh(j), ysourceMesh(j)];
        delay_oblot = calcDelayFunction(sig_source(1),sig_source(2),x_car(1, 2),x_car(2, 2), c);
        delay_wieza = calcDelayFunction(sig_source(1),sig_source(2),x_car(1, 3),x_car(2, 3), c);
        delay_internat = calcDelayFunction(sig_source(1),sig_source(2),x_car(1, 4),x_car(2, 4), c);
        delay_szpital = calcDelayFunction(sig_source(1),sig_source(2),x_car(1, 5),x_car(2, 5), c);
        delays = [delay_oblot, delay_wieza, delay_internat, delay_szpital];
        for i = 1:iter
            TDOAs = getTDOAsXcorr(duration, delays, fs, signal_dvbt, -8, 2, 10, 1);
    
            [x_hat_opt, fval] = fminunc(@(x_hat) costFunctionLS_TDOA(x_hat, x_car, TDOAs, c), x0, options);
       
            fmu_error = norm(x_hat_opt(1:2) - sig_source(1:2));
    
            temp_errors_storage(i, 1) = fmu_error;
        end
        mean_errors(j) = (sum(temp_errors_storage))/iter;
        for k = 1:iter
            sqrtsum = sqrtsum + (temp_errors_storage(k, 1) - mean_errors(j))^2;
        end
        deviations(j) = sqrt(sqrtsum/iter)
    end
    
    figure('Name', 'Sources Mesh Mean Errors' )
    clims1 = [0 1000];
    imagesc(sourceRange, sourceRange, mean_errors, clims1);
    colorbar;
    set(gca, 'YDir', 'normal');
    hold on;
    plot(x_car(1, 2:5), x_car(2, 2:5), '^k', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');
    hold off

    figure('Name', 'Sources Mesh Deviation')
    clims2 = [0 5000];
    imagesc(sourceRange, sourceRange, deviations, clims2);
    colorbar;
    set(gca, 'YDir', 'normal');
    hold on;
    plot(x_car(1, 2:5), x_car(2, 2:5), '^k', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');

end