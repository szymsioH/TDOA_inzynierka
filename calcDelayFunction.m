function delay = calcDelayFunction(x_t, y_t, z_t, x_r, y_r, z_r, c)
    distance = sqrt((x_t - x_r)^2 + (y_t - y_r)^2 + (z_t - z_r)^2);
    delay = distance/c;
%----------------------------------------------------------

%-----------------------------------------------------------
end
