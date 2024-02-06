function [data] = PostProcessTimeSeries(obj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
data = struct();

crmData = obj.crm.Data;
pxiData = obj.pxi.Data;

% left_wingroot_strain
data.left_wingroot_strain = linearCalibration(...
    pxiData(:,obj.pxi.StrainA),obj.CalibMeta.StrainAGain,obj.CalibMeta.StrainAOffset);

% right_wingroot_strain
data.right_wingroot_strain = linearCalibration(...
    pxiData(:,obj.pxi.StrainB),obj.CalibMeta.StrainBGain,obj.CalibMeta.StrainBOffset);
% pxi time
data.pxi_time = (pxiData(:,obj.pxi.PacketNum) - pxiData(1,obj.pxi.PacketNum))/100;

% left_enc
data.left_enc = EncCalibration(...
    crmData(:,obj.crm.CntA),obj.CalibMeta.EncAGain,obj.CalibMeta.EncAOffset);

% right_enc
data.right_enc = EncCalibration(...
    crmData(:,obj.crm.CntB),obj.CalibMeta.EncBGain,obj.CalibMeta.EncBOffset);

data.left_wingtip_servo = crmData(:,obj.crm.ch(1)) - obj.CalibMeta.ServoZeroPos(1);
data.left_ail_servo = crmData(:,obj.crm.ch(2)) - obj.CalibMeta.ServoZeroPos(2);
data.right_ail_servo = crmData(:,obj.crm.ch(3)) - obj.CalibMeta.ServoZeroPos(3);
data.right_wingtip_servo = crmData(:,obj.crm.ch(4)) - obj.CalibMeta.ServoZeroPos(4);
data.left_elev_servo = crmData(:,obj.crm.ch(5)) - obj.CalibMeta.ServoZeroPos(5);
data.right_elev_servo = crmData(:,obj.crm.ch(6)) - obj.CalibMeta.ServoZeroPos(6);

data.crm_time = (crmData(:,obj.crm.PacketNum) - crmData(1,obj.crm.PacketNum))/100;
end

