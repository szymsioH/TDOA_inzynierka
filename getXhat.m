function [x_hat_opt, fval] = getXhat(TDOAs, x_car, c, scale)
    
%scale - ile razy dalej mniej więcej może być nadajnik, 10 bazowo

x0 = [0; 0];
options = optimoptions('fminunc','Algorithm','quasi-newton','Display','off');

if size(x0) ~= [2,1]
    disp('ŹLE WPISANY X0!!!!!  (x0 = [x; y])')
end

[x_hat_opt0, fval0] = fminunc(@(x_hat) costFunctionLS_TDOA(x_hat, x_car, TDOAs, c), x0, options);

% x_hat_opt = x_hat_opt0;
% fval = fval0;

R_difference = x_hat_opt0 - [0;0];

x01 = x_hat_opt0 + scale*R_difference;

[x_hat_opt1, fval1] = fminunc(@(x_hat) costFunctionLS_TDOA(x_hat, x_car, TDOAs, c), x01, options);

x_hat_opt = x_hat_opt1;
fval = fval1;

% if fval0 < fval1
%     x_hat_opt = x_hat_opt0;
%     fval = fval0;
% elseif fval0 > fval1
%     x_hat_opt = x_hat_opt1;
%     fval = fval1;
% elseif fval0 == fval1
%     x_hat_opt = x_hat_opt1;
%     fval = fval1;
% end







% err_folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo\errors_and_snr_tables';
% cd(err_folder);
% 
% file_name = 'rms_mesh_5_200_5_10iter.mat';
% 
% if exist(file_name, 'file') ~= 2
%     error('Plik %s nie istnieje.', file_name);
% end
% rmss_data = load(file_name);
% 
% folder = 'C:\Users\szymo\OneDrive\Pulpit\Inz_repo';
% cd(folder);
% 
% rms_mesh = transpose(rmss_data.rms_mesh);
% 
% source_singleidx = sub2ind(size(rms_mesh), source(1), source(2));
% 
% if ismember(source_singleidx, find(rms_mesh>100))
%     x01 = x_hat_opt0;
% else
%     R_difference = x_hat_opt0 - [0;0];
%     
%     x01 = x_hat_opt0 + scale*R_difference;
% end

% x01 = x_hat_opt0;

% [x_hat_opt, fval] = fminunc(@(x_hat) costFunctionLS_TDOA(x_hat, x_car, TDOAs, c), x01, options);

end

