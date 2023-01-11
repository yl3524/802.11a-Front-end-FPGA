function SIGNAL_INTERLEAVE = data_interleave(SIGNAL_encode, N_cbps, N_bpsc)

%DATA_INTERLEAVE Summary of this function goes here
%   interleave the encoded SIGNAL field bits

%   Detailed explanation goes here
%   SIGNAL_encode: encoded SIGNAL field bits
%   N_cbps: coded bits per OFDM symbol
%   N_bpsc: coded bits per subcarrier

    k = 0:1:N_cbps-1; % Index of the coded bit before the first permutation
    i = (N_cbps/16)*mod(k,16)+floor(k/16); % The index after the first and before the second permutation
    s = max(N_bpsc/2,1); 
    i_temp = 0:1:N_cbps-1;
    j = s.*floor(i_temp./s) + mod((i_temp+N_cbps-floor(16.*i_temp./N_cbps)),s); % Index after the second permutation prior to modulation
    SIGNAL_INTERLEAVE = zeros(1,N_cbps);
    SIGNAL_INTERLEAVE_temp = zeros(1,N_cbps);
    
    for count = 1:N_cbps % First permutation
        SIGNAL_INTERLEAVE_temp(i(count)+1) = SIGNAL_encode(k(count) + 1);
    end

    for count = 1:N_cbps % Second permutation
        SIGNAL_INTERLEAVE(j(count)+1) = SIGNAL_INTERLEAVE_temp(count);
    end

end

