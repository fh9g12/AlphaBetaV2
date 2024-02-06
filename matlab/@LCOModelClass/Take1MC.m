function [RunNumber,d]  = Take1MC(obj,ServoStr,amp,freq,time,opts)
arguments
    obj LCOModelClass
    ServoStr
    amp double
    freq double
    time double
    opts.PlotData = true;
    opts.Save = true;
end
%TAKE1MCGUST Summary of this function goes here
%   Detailed explanation goes here
fprintf('BeginMove...Amp %.0f...',amp);
obj.BufferSize = obj.Meta.Rate*(time+2);
obj.mqttClient.flush();
obj.Start();
pause(0.5);
obj.OneMinusCosine(ServoStr,freq,amp);
pause(time)
obj.Stop();
if opts.Save
    fprintf('Get Data...')
    obj.OHBData = OHBData.FromString(obj.ohb.readLastSample());
    [RunNumber,d]  = obj.saveTimeSeries();
end
if opts.PlotData
    figure(1);clf;
    obj.plotCalib();
    drawnow;
end
end

