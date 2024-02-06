function [out] = linearCalibration(val,gain,intercept)
%LINEARCALIBRATION Summary of this function goes here
%   Detailed explanation goes here
out = val*gain + intercept;
end


