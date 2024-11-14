function sig_source = signalSourceFunction(k)

%k - numer badanego nadajnika (1 - 15)

% każdy "storage" odpowiada zestawowi z jednej warstwy na mapie
% sprawdzić poprawną KOLEJNOŚĆ dodawanych elementów!

    sig_source_storage1 = [53.01471 53.01608 53.01373 53.02338 53.02503 53.03416 53.06099 53.14367 53.17619 53.40787 53.33908 52.41841 53.14351 52.27287 53.10225;
        20.90819 20.89291 20.92187 20.91514 20.89591 20.92502 20.95163 21.04709 21.14254 21.92783 21.46193 20.94549 23.14913 20.9509 22.41207;
%         120 120 120 120 120 120 120 120 120 120 120 120 120 120 120];
        zeros(1, 15)];

    sig_source_storage2 = [ 53.01834 52.98933 52.95033 52.91308 52.87 52.82521 52.75713 52.64742 52.52811 52.40764 52.27676 52.15807;
        20.90112 20.89805 20.89483 20.89035 20.88623 20.88348 20.87731 20.86973 20.85187 20.84363 20.8299 20.82122;
%         120 120 120 120 120 120 120 120 120 120 120 120];
        zeros(1, 12)];

    sig_source_storage = [sig_source_storage1 sig_source_storage2];

    sig_source = [sig_source_storage(1, k) sig_source_storage(2, k) sig_source_storage(3, k)];
    
end

