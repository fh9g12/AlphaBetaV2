function [RunNumber,d]  = TakeChirp(obj,servoStr,freq_start,freq_end,amp,time,opts)
arguments
    obj ABModelClass
    servoStr
    freq_start double
    freq_end double
    amp double
    time double
    opts.PlotData = true;
end
%TAKE1MCGUST Summary of this function goes here
%   Detailed explanation goes here

%% setup Gust

obj.BufferSize = ceil(obj.Meta.Rate*(time+5));

%% run test
obj.Meta.datetime = datetime();
fprintf('Start...')
obj.Start();
pause(2);
obj.ChirpWave(servoStr,freq_start,freq_end,amp,time);
pause(time+2);
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

