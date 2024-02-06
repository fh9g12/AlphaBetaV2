function [RunNumber,d] = TakeServoStepTimeSeries(obj,servo,datum,delta,opts)
arguments
    obj ABModelClass;
    servo
    datum
    delta
    opts.sampleTime double = 3;
    opts.TimeSeriesLength = 5;
    opts.PlotData = true;
    opts.SaveData = true;
end
%TAKESAMPLE Summary of this function goes here
%   Detailed explanation goes here

% record Ambient Conditions
obj.Meta.Pressure = obj.AmbientPressure;
obj.Meta.Temperature = obj.AmbientTemp;
obj.Meta.datetime = datetime();

%set pressure on OC
obj.ohb.setBaro(obj.Meta.Pressure);
fprintf('Set Baro...')
pause(0.25);
fprintf('Take Sample...')
Model.ohb.sample(opts.sampleTime);
pause(1);

fprintf('Move To Delfected Position...')
obj.StraightMove(servo,datum-delta,1);
pause(1.2);
fprintf('BeginMove...');
obj.Start();
pause(2);
obj.StraightMove(servo,datum,0);
pause(opts.TimeSeriesLength)
obj.Stop();
pause(0.25);
obj.OHBData = OHBData.FromString(obj.ohb.readLastSample());
if opts.SaveData
    fprintf('Save Data...')
    [RunNumber,d] = obj.saveTimeSeries();
else
    RunNumber = NaN;
    d = obj.ToTimeSeriesStruct();
end
if opts.PlotData
    figure(1);clf;
    obj.plotCalib();
    drawnow;
end
end

