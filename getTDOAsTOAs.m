function TDOAs = getTDOAsTOAs(delays)

    ref_receiver_delay = delays(1);

    TOA1 = delays(1)-ref_receiver_delay;
    TOA2 = delays(2)-ref_receiver_delay;
    TOA3 = delays(3)-ref_receiver_delay;
    TOA4 = delays(4)-ref_receiver_delay;
    
    %TOAs = [TOA1, TOA2, TOA3, TOA4];
    
    TDOA12 = TOA2 - TOA1;
    TDOA13 = TOA3 - TOA1;
    TDOA14 = TOA4 - TOA1;
    
    TDOAs = [TDOA12, TDOA13, TDOA14];

end

