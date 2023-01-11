function [wifi_sig, DATA_ext] = wifi_sig_gen(rate, octet_num, msg_bin)

%   WIFI_SIG_GEN Summary of this function goes here
%   This function is used to generate time-domain WiFi signal using
%   input message based on 802.11a WiFi standard and given data rate

%   wifi_sig: generated wifi signal in time-domain
%   rate: data rate (6, 9, 12, 18, 24, 36, 48, 54)
%   octet_num: number of octets in message
%   msg_bin: binary one-dimension array

% =========================================================================
% TIME-RELATED PARAMETERS:
%
% Subcarrier frequency spacing: delta_f = 0.3125MHz(=20MHz/64)
% IFFT/FFT period: t_fft = 3.2us(=1/delta_f) 
% PLCP preamble duration: t_preamble = 16us(=t_long+t_short)
% Duration of the SIGNAL BPSK-OFDM symbol: t_signal = 4.0us(=t_GI+t_fft)
% GI duration: t_GI = 0.8us(=t_fft/4)
% Training symbol GI duration: t_GI2 = 1.6us(=t_FFT/2)
% Symbol interval: t_sym = 4us(=t_GI+t_fft)
% Short training sequence duration: t_short = 8us(10*t_fft/4)
% Long training sequence duration: t_long = 8us(t_GI2 + 2*t_fft)
% =========================================================================

    %% PARAMETER DEFINITION
    
    [R, N_bpsc, N_cbps, N_dbps] = rate_lut(rate); % Specify system parameters
    
    % R: coding rate
    % N_bpsc: coded bits per subcarrier
    % N_cbps: coded bits per OFDM symbol
    % N_dbps: data bits per OFDM symbol
    
    N_sd = 48; % number of data subcarriers
    N_sp = 4; % number of pilot subcarriers
    N_st = N_sd + N_sp; % number of subcarriers, total
    
    % Pilot polarity
    P_0_126v = [1,1,1,1, -1,-1,-1,1, -1,-1,-1,-1, 1,1,-1,1, -1,-1,1,1, -1,1,1,-1, 1,1,1,1, 1,1,-1,1, ...
        1,1,-1,1, 1,-1,-1,1, 1,1,-1,1, -1,-1,-1,1, -1,1,-1,-1, 1,-1,-1,1, 1,1,1,1, -1,-1,1,1, ...
        -1,-1,1,-1, 1,-1,1,1, -1,-1,-1,1, 1,-1,-1,-1, -1,1,-1,-1, 1,-1,1,1, 1,1,-1,1, -1,1,-1,1, ...
        -1,-1,-1,-1, -1,1,-1,1, 1,-1,1,-1, 1,1,1,-1, -1,1,-1,-1, -1,1,1,1, -1,-1,-1,-1, -1,-1,-1];
    
    %% PREAMBLE FIELD
    
    % SHORT PREAMBLE 
    PREAMBLE_short_freq = sqrt(13/6) * [0,0,1+1i,0,0,0,-1-1i,0,0,0,1+1i,0,0,0,-1-1i, ...
        0,0,0,-1-1i,0,0,0,1+1i,0,0,0,0,0,0,0,-1-1i,0,0,0,-1-1i,0,0,0,1+1i,0,0,0,1+1i,...
        0,0,0,1+1i,0,0,0,1+1i,0,0];
    PREAMBLE_short_time_64 = ifft(rearange(PREAMBLE_short_freq));
    PREAMBLE_short_time_16 = PREAMBLE_short_time_64(1:16);
    PREAMBLE_short_time_161 = [repmat(PREAMBLE_short_time_16,1,10), PREAMBLE_short_time_16(1)];
    PREAMBLE_short_time_161(1) = 0.5 * PREAMBLE_short_time_161(1); % Window function
    PREAMBLE_short_time_161(161) = 0.5 * PREAMBLE_short_time_161(161); % Window function
    
    % LONG PREAMBLE
    PREAMBLE_long_freq = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, ...
        -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0, 1, -1, -1, 1, 1, -1, 1, -1, 1, -1, ...
        -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1];
    PREAMBLE_long_time_64 = ifft(rearange(PREAMBLE_long_freq));
    PREAMBLE_long_time_128 = repmat(PREAMBLE_long_time_64,1,2);
    PREAMBLE_long_time_161 = [PREAMBLE_long_time_128(97:128), PREAMBLE_long_time_128, PREAMBLE_long_time_128(1)];
    PREAMBLE_long_time_161(1) = 0.5 * PREAMBLE_long_time_161(1);
    PREAMBLE_long_time_161(161) = 0.5 * PREAMBLE_long_time_161(161);
    
    %% SIGNAL FIELD
    
    RATE = rate2bin(rate);
    LENGTH = flip(transpose(int2bit(octet_num,  12)));
    SIGNAL_TAIL = [0,0,0,0,0,0];
    PARITY = 0;
    RESERVE = 0;
    
    SIGNAL_24 = [RATE, RESERVE, LENGTH, PARITY, SIGNAL_TAIL]; % 24-bit SIGNAL field
    
    trellis = poly2trellis(7,[133,171]); % Establish 2BPSK convolutional encoder
    SIGNAL_48 = convenc(SIGNAL_24, trellis); % Generate encoding 48-bit SIGNAL field

    SIGNAL_48_intlv = data_interleave(SIGNAL_48, 48, 1);
    SIGNAL_48_freq = transpose(modulate_pattern(SIGNAL_48_intlv, 1)); % BPSK modulation

    pilot_vector = P_0_126v(1) * [1,1,1,-1]; 
    SIGNAL_53 = [SIGNAL_48_freq(1:5), pilot_vector(1), SIGNAL_48_freq(6:18), pilot_vector(2), SIGNAL_48_freq(19:24),0, ...
        SIGNAL_48_freq(25:30), pilot_vector(3), SIGNAL_48_freq(31:43), pilot_vector(4), SIGNAL_48_freq(44:48)];

    SIGNAL_64_freq = rearange(SIGNAL_53); % Reorder
    SIGNAL_64_time = ifft(SIGNAL_64_freq);
    SIGNAL_81_time = [SIGNAL_64_time(49:64), SIGNAL_64_time, SIGNAL_64_time(1)];
    SIGNAL_81_time(1) = 0.5 * SIGNAL_81_time(1); % Window function
    SIGNAL_81_time(81) = 0.5 * SIGNAL_81_time(81); % Window function

    %% DATA FIELD
    
    puncpat = puncture_pattern(R); % define pucture pattern(how bits are stolen)
    SERVICE_bit = zeros(1,16);
    TAIL_bit = zeros(1,6);
    DATA = [SERVICE_bit, msg_bin, TAIL_bit];

    packet_num = ceil(length(DATA)/N_dbps);
    DATA_ext = zeros(1,packet_num * N_dbps); % extended data
    DATA_ext(1:length(DATA)) = DATA;

    % Scrambler
    DATA_scrambled = wlanScramble(transpose(DATA_ext), 93); % Put all data through scrambler, the initial state is 93
    DATA_scrambled = transpose(DATA_scrambled);
    DATA_scrambled(length(DATA)-5:length(DATA)) = 0; % TAIL bit zeroed
    DATA_encoded = convenc(DATA_scrambled, trellis, puncpat);

    % Encoding
    DATA_field = [0];
    for i = 1:1:packet_num
        DATA_inlv = data_interleave(DATA_encoded(1+N_cbps*(i-1):N_cbps*i), N_cbps, N_bpsc);
        DATA_inlv_bin = int64(transpose(DATA_inlv)); % convert to int type
        DATA_qammod = modulate_pattern(DATA_inlv_bin, N_bpsc);
        pilot_vector = P_0_126v(i+1)*[1,1,1,-1]; % define the pilot polarity for signal field
        DATA_53sc = [DATA_qammod(1:5), pilot_vector(1), DATA_qammod(6:18), pilot_vector(2), ...
            DATA_qammod(19:24), 0, DATA_qammod(25:30), pilot_vector(3), DATA_qammod(31:43), pilot_vector(4), DATA_qammod(44:48)];
        DATA_64_time = ifft(rearange(DATA_53sc));
        DATA_81_time = [DATA_64_time(49:64), DATA_64_time, DATA_64_time(1)];
        DATA_81_time(1) = 0.5 * DATA_81_time(1);
        DATA_81_time(81) = 0.5 * DATA_81_time(81);
    
        DATA_field(end) = DATA_field(end) + DATA_81_time(1);
        DATA_field = [DATA_field, DATA_81_time(2:end)];
    end
    
    %% OVERALL TIME-DOMAIN SIGNAL INTEGRATION

    wifi_sig = [PREAMBLE_short_time_161(1:160), PREAMBLE_short_time_161(end) + PREAMBLE_long_time_161(1), ...
        PREAMBLE_long_time_161(2:end-1), PREAMBLE_long_time_161(end)+SIGNAL_81_time(1), ...
        SIGNAL_81_time(2:end-1), SIGNAL_81_time(end)+DATA_field(1), DATA_field(2:end)];
    time_pt = length(wifi_sig);
    time = 0.05 * (1:time_pt);
    plot(time, abs(wifi_sig));
    xlabel('time(\mus)')
    ylabel('signal amplitude')

end

