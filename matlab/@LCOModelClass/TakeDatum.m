function [RunNumber,d]  = TakeDatum(obj,opts)
arguments
    obj LCOModelClass
    opts.time double = 5;
    opts.PlotData = true;
end
%TAKEDATUM Summary of this function goes here
%   Detailed explanation goes here

obj.Meta.RunType = 'Datum';
obj.Meta.isDatum = true;
obj.Meta.ZeroRun = nan;
fprintf('zeroing serovos...\n')
obj.ZeroServos();
fprintf('Moving to Zero Yaw...\n')
obj.ohb.moveYaw(0,2,2,2,blocking=true);
pause(2);
fprintf('Taking Zero Sample...\n')
[RunNumber,d] = obj.TakeSample(opts.time,'PlotData',opts.PlotData);
fprintf('Datum Complete, Run Number: %.0f\n',RunNumber);
end

