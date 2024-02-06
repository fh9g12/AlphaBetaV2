function runTest(obj,test_length)
%RUNTEST Summary of this function goes here
%   Detailed explanation goes here
arguments
    obj
    test_length = nan
end
if isnan(test_length)
    test_length = obj.Meta.RunDuration + obj.Meta.PreRunPauseDuration + obj.Meta.PostRunPauseDuration;
end
obj.BufferSize = ceil(obj.Meta.Rate*(test_length));
obj.Meta.datetime = datetime();
obj.Start();
pause(test_length)
obj.Stop();
end

