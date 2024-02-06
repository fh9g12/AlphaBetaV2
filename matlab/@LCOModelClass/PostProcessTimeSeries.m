function [data] = PostProcessTimeSeries(obj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
data = struct();

crmData = obj.crm.Data;
pxiData = obj.pxi.Data;

% wingroot_strain
data.wingroot_strain = linearCalibration(...
    pxiData(:,obj.pxi.StrainA),obj.CalibMeta.StrainAGain,obj.CalibMeta.StrainAOffset);

% % Z_h
% data.Z_h = linearCalibration(pxiData(:,obj.pxi.Z_h),1,0);
% data.X_h = linearCalibration(pxiData(:,obj.pxi.X_h),1,0);
% pxi time
data.pxi_time = (pxiData(:,obj.pxi.PacketNum) - pxiData(1,obj.pxi.PacketNum))/100;

% enc
data.enc = EncCalibration(crmData(:,obj.crm.CntA),obj.CalibMeta.EncAGain,obj.CalibMeta.EncAOffset);

% servos
data.left_wingtip_servo = crmData(:,obj.crm.ch(1)) - obj.CalibMeta.ServoZeroPos(1);
data.left_ail_servo = crmData(:,obj.crm.ch(2)) - obj.CalibMeta.ServoZeroPos(2);
data.right_ail_servo = crmData(:,obj.crm.ch(3)) - obj.CalibMeta.ServoZeroPos(3);
data.right_wingtip_servo = crmData(:,obj.crm.ch(4)) - obj.CalibMeta.ServoZeroPos(4);
data.left_elev_servo = crmData(:,obj.crm.ch(5)) - obj.CalibMeta.ServoZeroPos(5);
data.right_elev_servo = crmData(:,obj.crm.ch(6)) - obj.CalibMeta.ServoZeroPos(6);

data.crm_time = (crmData(:,obj.crm.PacketNum) - crmData(1,obj.crm.PacketNum))/100;
end

