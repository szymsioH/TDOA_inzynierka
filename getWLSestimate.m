function x_hat_opt = getWLSestimate(TDOAs, x_car, c, fs)
    

    D = [((x_car(1, 2)^2) + (x_car(2, 2)^2)), ((x_car(1, 3)^2) + (x_car(2, 3)^2)), ((x_car(1, 4)^2) + (x_car(2, 4)^2)), ((x_car(1, 5)^2) + (x_car(2, 1)^5))];

    G = 2*[TDOAs(2)*x_car(1, 3) - TDOAs(1)*x_car(1, 4), TDOAs(2)*x_car(2, 3) - TDOAs(1)*x_car(2, 4);
        TDOAs(3)*x_car(1, 3) - TDOAs(1)*x_car(1, 5), TDOAs(3)*x_car(2, 3) - TDOAs(1)*x_car(2, 5)];

    h = [TDOAs(2)*D(2) - TDOAs(1)*D(3) + (c^2)*TDOAs(1)*TDOAs(2)*(TDOAs(2)-TDOAs(1));
        TDOAs(3)*D(2) - TDOAs(1)*D(4) + (c^2)*TDOAs(1)*TDOAs(3)*(TDOAs(3)-TDOAs(1))];

    sls = ( ((G.').*G).^(-1) ).*(G.').*h;

%     alpha = [-D(3) + (c^2)*(TDOAs(2)^2 - 2*TDOAs(1)*TDOAs(2)) + 2*x_car(1, 4)*sls(1) - 2*x_car(2, 4)*sls(2);
%         -D(4) + (c^2)*(TDOAs(3)^2 - 2*TDOAs(1)*TDOAs(3)) + 2*x_car(1, 5)*sls(1) - 2*x_car(2, 5)*sls(2)];
% 
%     beta = [D(2) - (c^2)*(TDOAs(1)^2 - 2*TDOAs(1)*TDOAs(2)) - 2*x_car(1, 3)*sls(1) - 2*x_car(2, 3)*sls(2);
%         D(2) - (c^2)*(TDOAs(1)^2 - 2*TDOAs(1)*TDOAs(3)) - 2*x_car(1, 3)*sls(1) - 2*x_car(2, 3)*sls(2)];
% 
%     Var_phi = [(alpha(1)^2 + beta(1).^2) .* sigma_n^2; 
%         (alpha(2)^2 + beta(2)^2) * sigma_n^2]
% 
%     Cov_phi = diag(Var_phi)
% 
%     W = Cov_phi.^(-1)
% 
%     s = ((G.'.*W.*G)^(-1) ) .*G.'.*W.*h;

%     phi = [alpha(1)*errors_fs(1) + beta(1)*errors_fs(2);
%         alpha(2)*errors_fs(1) + beta(2)*errors_fs(3)];

    x_hat_opt = sls;

end

