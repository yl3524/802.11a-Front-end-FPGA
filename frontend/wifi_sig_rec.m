function wifi_msg = wifi_sig_rec(varargin)

%WIFI_SIG_REC Summary of this function goes here
%   Restore wifi message from time-domain signal

%   Detailed explanation goes here
%   wifi_msg: wifi message in bianry array

%   One input parameter if no noise added
%   Two input parameters of gaussian noised added
%   wifi_sig_time: time-domain wifi signal
%   snr: signal noise rate

    wifi_pmd = varargin{1}(160+160+1:end); % Remove Preamble Long and Short

    % Noise generation ----------------------------------------------------
    if(length(varargin) == 2)
        snr = varargin{2};
        sigpower = pow2db(mean(abs(wifi_pmd).^2));
        wifi_pmd = awgn(wifi_pmd,snr,sigpower);
    end

    % SIGNAL field --------------------------------------------------------
    SIGNAL_80 = wifi_pmd(1:80);
    SIGNAL_64 = SIGNAL_80(17:end); % Remove GI
    SIGNAL_64_freq = fft(SIGNAL_64);
    SIGNAL_53_freq = derearange(SIGNAL_64_freq);
    SIGNAL_48_freq = [SIGNAL_53_freq(1:5), SIGNAL_53_freq(7:19), SIGNAL_53_freq(21:26), ...
        SIGNAL_53_freq(28:33), SIGNAL_53_freq(35:47), SIGNAL_53_freq(49:53)];
    SIGNAL_48_freq_intlv = demodulate_pattern(SIGNAL_48_freq, 1);
    SIGNAL_48 = data_deinterleave(SIGNAL_48_freq_intlv, 48, 1);
    trellis = poly2trellis(7,[133,171]);
    SIGNAL_24 = vitdec(SIGNAL_48, trellis, 5,'trunc','hard');
    
    % Extract information from SIGNAL field
    RATE = SIGNAL_24(1:4);
    [RATE_int, R, N_bpsc, N_cbps, N_dbps] = decode_rate(RATE); % Decode demodulation parameters from Rate field
    puncpat = puncture_pattern(R); % Generate puncture pattern from devoded R
    RESERVE = SIGNAL_24(5);
    LENGTH = SIGNAL_24(6:17);
    LENGTH_int = bin2int(LENGTH);
    PARITY = SIGNAL_24(18);
    SIGNAL_TAIL = SIGNAL_24(19:end);

    % DATA field ----------------------------------------------------------
    packet_num = ceil((8 * LENGTH_int + 22)/N_dbps); % Bits will be prepended 
    % with 16 SERVICE field bits and 6 tail bits(22 in total)
    DATA_encoded = [];
    for i = 1:1:packet_num
        DATA_field =wifi_pmd(81+80*(i-1):81+80*i-1);
        DATA_64 = DATA_field(17:end);
        DATA_64_freq = fft(DATA_64);
        DATA_53_freq = derearange(DATA_64_freq);
        DATA_48_freq = [DATA_53_freq(1:5), DATA_53_freq(7:19), DATA_53_freq(21:26), ...
            DATA_53_freq(28:33), DATA_53_freq(35:47), DATA_53_freq(49:53)];
        DATA_48_freq_intlv = demodulate_pattern(DATA_48_freq, N_bpsc);
        DATA_48 = data_deinterleave(DATA_48_freq_intlv, N_cbps, N_bpsc);
        DATA_encoded = [DATA_encoded, DATA_48];
    end
    DATA_scrambled = vitdec(DATA_encoded, trellis, 10, 'trunc', 'hard', puncpat);
    DATA = transpose(wlanScramble(transpose(DATA_scrambled), 93));
    DATA(8 * LENGTH_int + 17 : 8 * LENGTH_int + 22) = 0;
    wifi_msg = DATA;
end

