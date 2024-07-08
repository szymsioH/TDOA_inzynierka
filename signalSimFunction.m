function delays = signalSimFunction(x_car, x_geo, sig_source, c)
    
    %Obliczanie ENU:
    wgs84 = wgs84Ellipsoid("meter");
    
    %nadajnik
    [xEast_nadajnik,yNorth_nadajnik,zUp_nadajnik] = geodetic2enu(sig_source(1),sig_source(2),sig_source(3),x_geo(1, 1),x_geo(2, 1),x_geo(3, 1),wgs84);
    
    %delays
    delay_oblot = calcDelayFunction(xEast_nadajnik,yNorth_nadajnik,zUp_nadajnik,x_car(1, 2),x_car(2, 2),x_car(3, 2), c);
    delay_wieza = calcDelayFunction(xEast_nadajnik,yNorth_nadajnik,zUp_nadajnik,x_car(1, 3),x_car(2, 3),x_car(3, 3), c);
    delay_internat = calcDelayFunction(xEast_nadajnik,yNorth_nadajnik,zUp_nadajnik,x_car(1, 4),x_car(2, 4),x_car(3, 4), c);
    delay_szpital = calcDelayFunction(xEast_nadajnik,yNorth_nadajnik,zUp_nadajnik,x_car(1, 5),x_car(2, 5),x_car(3, 5), c);

    delays = [delay_oblot, delay_wieza, delay_internat, delay_szpital];

end

