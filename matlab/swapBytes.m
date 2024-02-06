function [new_str] = swapBytes(hex_str)
%SWAPBYTES Summary of this function goes here
%   Detailed explanation goes here
new_str = hex_str;
N = length(hex_str);
for i = 1:N/2
    new_str(N-1-2*(i-1)) = hex_str(2*(i-1)+1);
    new_str(N-2*(i-1)) = hex_str(2*i);
end

