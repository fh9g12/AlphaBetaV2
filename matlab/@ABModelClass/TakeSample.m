function [RunNumber,d] = TakeSample(obj,seconds,opts)
arguments
    obj
    seconds double = 3;
    opts.PlotData = true;
    opts.Save = true;
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
obj.ohb.sample(seconds);
obj.runTest(seconds);
pause(0.5);
obj.OHBData = OHBData.FromString(obj.ohb.readLastSample());
if opts.Save
    [RunNumber,d] = obj.saveSample();
end
if opts.PlotData
    figure(1);clf;
    obj.plotCalib();
    drawnow;
end
end

