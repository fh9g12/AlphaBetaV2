function [RunNumber,d]  = TakeTurbGust(obj,amp,time,opts)
arguments
    obj ABModelClass
    amp double
    time double
    opts.PlotData = true;
end
%TAKE1MCGUST Summary of this function goes here
%   Detailed explanation goes here

%% setup Gust
gt = obj.TurbGust(amp,time,0);
obj.BufferSize = ceil(obj.Meta.Rate*(time+4));

%% run test
obj.Meta.datetime = datetime();
fprintf('Start...')
obj.Start();
pause(2);
start(gt);
wait(gt);
pause(1);
obj.Stop();
fprintf('Get Data...')
obj.OHBData = OHBData.FromString(obj.ohb.readLastSample());
[RunNumber,d]  = obj.saveTimeSeries();
if opts.PlotData
    figure(1);clf;
    obj.plotCalib();
    drawnow;
end
end

