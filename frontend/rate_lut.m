function [R, N_bpsc, N_cbps, N_dbps] = rate_lut(rate)

%RATE_LUT Summary of this function goes here
%   Rate Look-up-table sepcifies paramters below.

%   Detailed explanation goes here
%   R: Coding rate(1/2, 3/4, 2/3)
%   N_bpsc: Coded bits per subcarrier(1, 2, 4, 6)
%   N_cbps: Coded bits per OFDM symbol(= N_bpsc * 48)
%   N_dbps: Data bits per OFDM symbol(= N_cbps * R)

    switch rate
        case 6
            R = 1/2;
            N_bpsc = 1;
        case 9
            R = 3/4;
            N_bpsc = 1;
        case 12
            R = 1/2;
            N_bpsc = 2;
        case 18
            R = 3/4;
            N_bpsc = 2;
        case 24
            R = 1/2;
            N_bpsc = 4;
        case 36
            R = 3/4;
            N_bpsc = 4;
        case 48
            R = 2/3;
            N_bpsc = 6;
        case 54
            R = 3/4;
            N_bpsc = 6;
    end 
    N_cbps = 48 * N_bpsc;
    N_dbps = N_cbps * R;

end

