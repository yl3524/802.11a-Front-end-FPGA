function output = rearange(input)

%REARANGE Summary of this function goes here
%   Rearange the 64-element input array

%   Detailed explanation goes here
%   -26 - 26 correspond to 0 - 63

    output0 = input(1:26); % -26 - -1
    output1 = input(28:53); % 1 - 26
    output = [0,output1,0,0,0,0,0,0,0,0,0,0,0,output0];
    
end

