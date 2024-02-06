function [RunNumber,d]  = TakeTimeSeries(obj,time,opts)
arguments
    obj LCOModelClass
    time double
    opts.PlotData = true;
    opts.Save = true;
    opts.TakeOCSample = false;
end
%TAKE1MCGUST Summary of this function goes here
%   Detailed explanation goes here
obj.BufferSize = ceil(obj.Meta.Rate*(time+2));
if opts.TakeOCSample
    % record Ambient Conditions
    obj.Meta.Pressure = obj.AmbientPressure;
    obj.Meta.Temperature = obj.AmbientTemp;

    %set pressure on OC
    obj.ohb.setBaro(obj.Meta.Pressure);
    fprintf('Set Baro...')
    pause(0.25);
    fprintf('Take Sample...')
    obj.ohb.sample(time);
end
%% run test
obj.Meta.datetime = datetime();
fprintf('Start...')
obj.Start();
pause(time+2);
obj.Stop();
fprintf('Get Data...')
obj.OHBData = OHBData.FromString(obj.ohb.readLastSample());
if opts.Save
    [RunNumber,d]  = obj.saveTimeSeries();
else
    fprintf('\n');
end
if opts.PlotData
    figure(1);clf;
    obj.plotCalib();
    drawnow;
end
end

