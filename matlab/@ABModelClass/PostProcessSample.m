function [data] = PostProcessSample(obj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
data = struct();

crmData = obj.crm.Data;
pxiData = obj.pxi.Data;

%% left_wingroot_strain
val = linearCalibration(...
    pxiData(:,obj.pxi.StrainA),obj.CalibMeta.StrainAGain,obj.CalibMeta.StrainAOffset);
data.left_wingroot_strain.mean = mean(val);
data.left_wingroot_strain.std = std(val);

%% right_wingroot_strain
val = linearCalibration(...
    pxiData(:,obj.pxi.StrainB),obj.CalibMeta.StrainBGain,obj.CalibMeta.StrainBOffset);
data.right_wingroot_strain.mean = mean(val);
data.right_wingroot_strain.std = std(val);

%% left_enc
val = EncCalibration(...
    crmData(:,obj.crm.CntA),obj.CalibMeta.EncAGain,obj.CalibMeta.EncAOffset);
data.left_enc.mean = mean(val);
data.left_enc.std = std(val);

%% right_enc
val = EncCalibration(...
    crmData(:,obj.crm.CntB),obj.CalibMeta.EncBGain,obj.CalibMeta.EncBOffset);
data.right_enc.mean= mean(val);
data.right_enc.std = std(val);

%% Servos
left_wingtip_servo = crmData(:,obj.crm.ch(1)) - obj.CalibMeta.ServoZeroPos(1);
data.left_wingtip_servo.mean = mean(left_wingtip_servo);
data.left_wingtip_servo.std = std(left_wingtip_servo);
left_ail_servo = crmData(:,obj.crm.ch(2)) - obj.CalibMeta.ServoZeroPos(2);
data.left_ail_servo.mean = mean(left_ail_servo);
data.left_ail_servo.std = std(left_ail_servo);
right_ail_servo = crmData(:,obj.crm.ch(3)) - obj.CalibMeta.ServoZeroPos(3);
data.right_ail_servo.mean = mean(right_ail_servo);
data.right_ail_servo.std = std(right_ail_servo);
right_wingtip_servo = crmData(:,obj.crm.ch(4)) - obj.CalibMeta.ServoZeroPos(4);
data.right_wingtip_servo.mean = mean(right_wingtip_servo);
data.right_wingtip_servo.std = std(right_wingtip_servo);

left_elev_servo = crmData(:,obj.crm.ch(5)) - obj.CalibMeta.ServoZeroPos(5);
data.left_elev_servo.mean = mean(left_elev_servo);
data.left_elev_servo.std = std(left_elev_servo);
right_elev_servo = crmData(:,obj.crm.ch(6)) - obj.CalibMeta.ServoZeroPos(6);
data.right_elev_servo.mean = mean(right_elev_servo);
data.right_elev_servo.std = std(right_elev_servo);
end

