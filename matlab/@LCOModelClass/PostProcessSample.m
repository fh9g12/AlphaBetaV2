function [data] = PostProcessSample(obj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
data = struct();

crmData = obj.crm.Data;
pxiData = obj.pxi.Data;

%% wingroot_strain
val = linearCalibration(...
    pxiData(:,obj.pxi.StrainA),obj.CalibMeta.StrainAGain,obj.CalibMeta.StrainAOffset);
data.wingroot_strain.mean = mean(val);
data.wingroot_strain.std = std(val);

% %% Z_h
% val = linearCalibration(pxiData(:,obj.pxi.X_h),1,0);
% data.Z_h.mean = mean(val);
% data.Z_h.std = std(val);
% 
% %% X_h
% val = linearCalibration(pxiData(:,obj.pxi.X_h),1,0);
% data.X_h.mean = mean(val);
% data.X_h.std = std(val);

%% enc
val = EncCalibration(...
    crmData(:,obj.crm.CntA),obj.CalibMeta.EncAGain,obj.CalibMeta.EncAOffset);
data.enc.mean = mean(val);
data.enc.std = std(val);

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

