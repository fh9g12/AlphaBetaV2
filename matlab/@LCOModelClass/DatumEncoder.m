function DatumEncoder(obj,angle,filename)
arguments
    obj
    angle
    filename (1,:) char = '__LCOencOffsets__.mat';
end
%DATUMENCODERS Summary of this function goes here
%   Detailed explanation goes here
obj.runTest(3);
crmData = obj.crm.Data;

%encoder
crmData(:,obj.crm.CntA) = EncCalibration(...
    crmData(:,obj.crm.CntA),obj.CalibMeta.EncAGain,0);

act_angle = mean(crmData(:,obj.crm.CntA));
obj.CalibMeta.EncAOffset = angle-act_angle;

res = struct();
res.EncAOffset = obj.CalibMeta.EncAOffset;
res.EncBOffset = obj.CalibMeta.EncBOffset;
save(filename,'res');
fprintf('Saved Encoder datums to file: %s\n',filename);
end

