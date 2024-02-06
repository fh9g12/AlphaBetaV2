function DatumEncoders(obj,angle,which,filename)
arguments
    obj
    angle
    which (1,:) char {mustBeMember(which,{'left','right','both'})} = 'both';
    filename (1,:) char = '__encOffsets__.mat';
end
%DATUMENCODERS Summary of this function goes here
%   Detailed explanation goes here
obj.runTest(3);
crmData = obj.crm.Data;

% left encoder
crmData(:,obj.crm.CntA) = EncCalibration(...
    crmData(:,obj.crm.CntA),obj.CalibMeta.EncAGain,0);
% right encoder
crmData(:,obj.crm.CntB) = EncCalibration(...
    crmData(:,obj.crm.CntB),obj.CalibMeta.EncBGain,0);

left_angle = mean(crmData(:,obj.crm.CntA));
right_angle = mean(crmData(:,obj.crm.CntB));

if ismember(which,{'left','both'})
    obj.CalibMeta.EncAOffset = angle-left_angle;
end
if ismember(which,{'right','both'})
    obj.CalibMeta.EncBOffset = angle-right_angle;% + angle*obj.CalibMeta.EncBGain;
end
res = struct();
res.EncAOffset = obj.CalibMeta.EncAOffset;
res.EncBOffset = obj.CalibMeta.EncBOffset;
save(filename,'res');
fprintf('Saved Encoder datums to file: %s\n',filename);
end

