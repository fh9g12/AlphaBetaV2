function [angle] = EncCalibration(cnts,gain,offset)
%ENCCALIBRATION Summary of this function goes here
%   Detailed explanation goes here
% cnts = cnts - offset + 2047;
% if cnts<0
%     cnts = cnts + 4096;
% elseif cnts>2047
%     cnts = cnts - 4096;
% end
% angle = (cnts-2047)*gain;

angle = (cnts - 2047)*gain+offset;
angle(angle>180) = angle(angle>180) - 360;
angle(angle<-180) = angle(angle<-180) + 360;
end

