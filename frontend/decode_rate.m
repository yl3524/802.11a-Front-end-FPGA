function [data_rate, R, N_bpsc, N_cbps, N_dbps] = decode_rate(RATE)

%DECODE_RATE Summary of this function goes here
%   Extract data rate, R, N_bpsc and N_cbps from decoded RATE bits

%   Detailed explanation goes here
%   RATE: four-bit bianry array

    if RATE == [1,1,0,1]
        data_rate = 6;
        R = 1/2;
        N_bpsc = 1;
    elseif RATE == [1,1,1,1]
        data_rate = 9;
        R = 3/4;
        N_bpsc = 1;
    elseif RATE == [0,1,0,1]
        data_rate = 12;
        R = 1/2;
        N_bpsc = 2;
    elseif RATE == [0,1,1,1]
        data_rate = 18;
        R = 3/4;
        N_bpsc = 2;
    elseif RATE == [1,0,0,1]
        data_rate = 24;
        R = 1/2;
        N_bpsc = 4;
    elseif RATE == [1,0,1,1]
        data_rate = 36;
        R = 3/4;
        N_bpsc = 4;
    elseif RATE == [0,0,0,1]
        data_rate = 48;
        R = 2/3;
        N_bpsc = 6;
    elseif RATE == [0,0,1,1]
        data_rate = 54;
        R = 3/4;
        N_bpsc = 6;
    end
    N_cbps = 48 * N_bpsc;
    N_dbps = N_cbps * R;

end

