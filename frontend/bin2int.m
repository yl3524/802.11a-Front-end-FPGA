function out = bin2int(input)
%BIN2INT Summary of this function goes here
%   Detailed explanation goes here
    out = 0;
    num = length(input);
    for i = 1:1:num
        out = out + input(i) * (2^(i-1));
    end

end

