function puncturePattern = puncture_pattern(dataRate)

%PUNCTURE_PATTERN Summary of this function goes here
%   decided puncture pattern based on rate

%   Detailed explanation goes here
%   rate includes 3/4, 2/3, 1/2

    switch dataRate
        case 3/4
            puncturePattern = [1;1;1;0;0;1];
        case 2/3
            puncturePattern = [1;1;1;0];
        case 1/2
            puncturePattern = [1;1;];
    end 
    
end

