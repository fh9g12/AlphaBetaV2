function [crmData,pxiData] = CalibData(obj)
%CALIBDATA Summary of this function goes here
%   Detailed explanation goes here
crmData = obj.crm.Data;
pxiData = obj.pxi.Data;

% left strain gauge
pxiData(:,obj.pxi.StrainA) = linearCalibration(...
    pxiData(:,obj.pxi.StrainA),obj.CalibMeta.StrainAGain,obj.CalibMeta.StrainAOffset);
%right strain gauge
pxiData(:,obj.pxi.StrainB) = linearCalibration(...
    pxiData(:,obj.pxi.StrainB),obj.CalibMeta.StrainBGain,obj.CalibMeta.StrainBOffset);
% left encoder
crmData(:,obj.crm.CntA) = EncCalibration(...
    crmData(:,obj.crm.CntA),obj.CalibMeta.EncAGain,obj.CalibMeta.EncAOffset);
% right encoder
crmData(:,obj.crm.CntB) = EncCalibration(...
    crmData(:,obj.crm.CntB),obj.CalibMeta.EncBGain,obj.CalibMeta.EncBOffset);
end

