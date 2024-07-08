function [x_car, x_geo] = receiversPositionFunction()

    %Odbiorniki:
    phi_oblot = 53.009528388;
    lambda_oblot = 20.9263071083;
    h_oblot = 116.2;
    
    phi_wieza = 53.013698444;
    lambda_wieza = 20.9306295361;
    h_wieza = 119.1;
    
    phi_internat = 53.014901583 ;
    lambda_internat = 20.8811312194;
    h_internat = 120;
    
    phi_szpital = 53.028219027;
    lambda_szpital = 20.8953601972 ;
    h_szpital = 118.8;

    %PUNKT ODNIESIENIA
    phi_ref = 53.01735;
    lambda_ref = 20.90708;
    h_ref = 0;
    
    %Obliczanie ENU:
    wgs84 = wgs84Ellipsoid("meter");
    
    %przyjmujemy Oblot za punkt odniesienia
    xEast_ref = 0;
    yNorth_ref = 0;
    zUp_ref = 0;
    
    %odbiorniki
    [xEast_oblot,yNorth_oblot,zUp_oblot] = geodetic2enu(phi_oblot,lambda_oblot,h_oblot,phi_ref,lambda_ref,h_ref,wgs84);
    [xEast_wieza,yNorth_wieza,zUp_wieza] = geodetic2enu(phi_wieza,lambda_wieza,h_wieza,phi_ref,lambda_ref,h_ref,wgs84);
    [xEast_internat,yNorth_internat,zUp_internat] = geodetic2enu(phi_internat,lambda_internat,h_internat,phi_ref,lambda_ref,h_ref,wgs84);
    [xEast_szpital,yNorth_szpital,zUp_szpital] = geodetic2enu(phi_szpital,lambda_szpital,h_szpital,phi_ref,lambda_ref,h_ref,wgs84);

    %PIERWSZYA KOLUMNA TO PUNKT ODNIESIENIA!!!

    x_car = [xEast_ref xEast_oblot xEast_wieza xEast_internat xEast_szpital;yNorth_ref yNorth_oblot yNorth_wieza yNorth_internat yNorth_szpital;zUp_ref zUp_oblot zUp_wieza zUp_internat zUp_szpital];
    x_geo = [phi_ref phi_oblot phi_wieza phi_internat phi_szpital;lambda_ref lambda_oblot lambda_wieza lambda_internat lambda_szpital;h_ref h_oblot h_wieza h_internat h_szpital];
end