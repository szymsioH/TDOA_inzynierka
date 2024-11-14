function J = costFunctionLS_TDOA(x_hat, x_car, TDOAs, c)
%x_hat - wektor współrzędnych estymowanego źródła.
%x - macierz współrzędnych odbiorników, każda kolumna to współrzędne jednego sensora.
%TDOAs - wektor zmierzonych czasów TDOA.
%c - predkosc propagacji sygnalu (3*10^8)
    N = length(TDOAs);
    J = 0;
    for i = 1:N
        term1 = TDOAs(i) * c;
        term2 = norm(x_hat - x_car(1:2, i+2));
        term3 = norm(x_hat - x_car(1:2, 2));
        J = J + (term1 - term2 + term3).^2;
    end


%     J = 0;
%     N = length(TDOAs);
%     for i = 1:N-1
%         Td = TDOAs.';
%         d = norm(x_hat(1:2) - x_car(1:2, i+2)) - norm(x_hat(1:2) - x_car(1:2, 2));
%         J = J + ((d/c) - TDOAs(i))^2;
%     end


end

