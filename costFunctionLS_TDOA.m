function J = costFunctionLS_TDOA(x_hat, x_car, TDOAs, c)
%x_hat - wektor współrzędnych estymowanego źródła.
%x - macierz współrzędnych odbiorników, każda kolumna to współrzędne jednego sensora.
%TDOAs - wektor zmierzonych czasów TDOA.
%c - predkosc propagacji sygnalu (3*10^8)
    N = length(TDOAs);
    J = 0;
    for i = 1:N
        term1 = TDOAs(i) * c;
        term2 = norm(x_hat - x_car(:, i+2));
        term3 = norm(x_hat - x_car(:, 2));
        J = J + (term1 - term2 + term3).^2;
    end

end