function sig_source = signalSourceFunction(k)

%k - numer badanego nadajnika (1 - 14)

    sig_source_storage = [53.01471 53.01608 53.01373 53.02338 53.02503 53.03416 53.06099 53.14367 53.17619 53.40787 53.33908 52.41841 53.14351 52.27287;
        20.90819 20.89291 20.92187 20.91514 20.89591 20.92502 20.95163 21.04709 21.14254 21.92783 21.46193 20.94549 23.14913 20.9509;
        118.5 120 123 110 119 120 120 120 120 120 120 120 120 120];

    sig_source = [sig_source_storage(1, k) sig_source_storage(2, k) sig_source_storage(3, k)];

    
    
end

