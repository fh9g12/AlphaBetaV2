function [RunNumber,d]  = TakeTimeSeries(obj,time,opts)
arguments
    obj ABModelClass
    time double
    opts.PlotData = true;
end
%TAKE1MCGUST Summary of this function goes here
%   Detailed explanation goes here

%% setup Gust
obj.BufferSize = ceil(obj.Meta.Rate*(time+2));
%% run test
obj.Meta.datetime = datetime();
fprintf('Start...')
obj.Start();
pause(time+1);
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

