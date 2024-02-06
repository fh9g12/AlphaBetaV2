function [RunNumber,d]  = Take1MCGust(obj,freq,amp,time,opts)
arguments
    obj LCOModelClass
    freq double
    amp double
    time double
    opts.PlotData = true;
end
%TAKE1MCGUST Summary of this function goes here
%   Detailed explanation goes here

%% setup Gust
gt = obj.OneMinusCosineGust(amp,freq,time);
obj.BufferSize = ceil(obj.Meta.Rate*(time+4));

%% run test
obj.Meta.datetime = datetime();
fprintf('Start...')
obj.Start();
pause(1);
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

