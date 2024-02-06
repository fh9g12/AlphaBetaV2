function [d] = ToTimeSeriesStruct(obj)
%T Summary of this function goes here
%   Detailed explanation goes here
warning('off','MATLAB:structOnObject');
d = obj.PostProcessTimeSeries();
d.Meta = obj.Meta.ToStruct();
d.Calib = obj.CalibMeta.ToStruct();
d.OHB = obj.OHBData.ToStruct();
warning('on','MATLAB:structOnObject');
end

