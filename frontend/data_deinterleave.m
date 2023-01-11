function SIGNAL_DEINTERLEAVE = data_deinterleave(SIGNAL_DECODE, N_cbps, N_bpsc)

%DATA_DEINTERLEAVE Summary of this function goes here
%   restore the interleaved data

%   Detailed explanation goes here

    j = 0:1:N_cbps-1;
    s = max(N_bpsc/2,1); 
    i = s .* floor(j./s) + mod((j+floor(16.*j./N_cbps)),s);
    i_temp = 0:1:N_cbps-1;
    k = 16.*i_temp - (N_cbps-1) .* floor(16*i_temp./N_cbps);
    SIGNAL_DEINTERLEAVE = zeros(1,N_cbps);
    SIGNAL_DEINTERLEAVE_temp = zeros(1,N_cbps);
    for count = 1:N_cbps % First permutation
        SIGNAL_DEINTERLEAVE_temp(i(count)+1) = SIGNAL_DECODE(j(count) + 1);
    end
    for count = 1:N_cbps % Second permutation
        SIGNAL_DEINTERLEAVE(k(count)+1) = SIGNAL_DEINTERLEAVE_temp(count);
    end

end

