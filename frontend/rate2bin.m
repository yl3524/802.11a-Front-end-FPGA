function output = rate2bin(input)

%RATE2BIN Summary of this function goes here
%   Convert rate to bianry bits in SIGNAL field
%   Detailed explanation goes here

    switch input
            case 6
                output = [1,1,0,1];
            case 9
                output = [1,1,1,1];
            case 12
                output = [0,1,0,1];
            case 18
                output = [0,1,1,1];
            case 24
                output = [1,0,0,1];
            case 36
                output = [1,0,1,1];
            case 48
                output = [0,0,0,1];
            case 54
                output = [0,0,1,1];
    end 

end

