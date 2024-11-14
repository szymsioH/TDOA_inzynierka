function delay = calcDelayFunction(x_t, y_t, x_r, y_r, c)
    distance = sqrt((x_t - x_r)^2 + (y_t - y_r)^2);
    delay = distance/c;
%----------------------------------------------------------

%-----------------------------------------------------------
end
