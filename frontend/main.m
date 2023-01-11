% INPUT DATA GENERATION ---------------------------------------------------

% The message being encoded consisted of the first 72 char of "Ode to Joy"
% by F. Schiller

% CHANGE CONTENT HERE IF YOU LIKE !!
data = uint8(['Joy, bright spark of divinity,' newline 'Daughter of Elysium,' ...
    newline 'Fire-insired we trea']); % in decimal form

mac_header = transpose(hex2dec(char('04', '02', '00', '2e', '00', '60', '08', ...
    'cd', '37', 'a6', '00', '20', 'd6', '01', '3c', 'f1', '00', '60', '08', ...
    'ad', '3b', 'af', '00', '00'))); % in decimal form

fcs = transpose(hex2dec(char('67', '33', '21', 'b6'))); % in decimal form

% Integrate to obtain transmission message

msg_char = dec2bin([mac_header, data, fcs]); % in binary form

% Write in binary data series
msg_octect_num = size(msg_char, 1);
msg_bin = zeros(1, msg_octect_num*8); % series 0/1
cnt = 1;
for i = 1 : 1 : msg_octect_num
    for j = 8 : -1 : 1
        msg_bin(cnt) = str2double(msg_char(i, j));
        cnt = cnt + 1;
    end
end

% TRANSMISSION FRONT-END --------------------------------------------------
% CHANGE CONFIGURATION AS YOU LIKE !!

[wifi_sig_time, wifi_msg] = wifi_sig_gen(36, msg_octect_num, msg_bin);

% RECEIVER FRONT-END ------------------------------------------------------
% CHANGE SNR to EXPLORE THE IMPACT FROM NOISE !!

SNR = 15;
wifi_msg_rst = wifi_sig_rec(wifi_sig_time, SNR); % restored wifi message
%wifi_msg_rst = wifi_sig_rec(wifi_sig_time); % restore wifi without injecting noise 

% ERROR RATE CHECK --------------------------------------------------------

fprintf('Error rate of message received when SNR = %d is %.2f percent\n', ...
    SNR, 100*mean(wifi_msg ~= wifi_msg_rst));




