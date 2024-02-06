function [fig_obj,plt_objs] = plotCalib(obj,plt_objs)
arguments
    obj ABModelClass;
    plt_objs = []
end
%DRAWDATA Summary of this function goes here
%   Detailed explanation goes here
[crmData,pxiData] = CalibData(obj);
fig_obj = figure(1);
persistent pxi_time_0;
persistent crm_time_0;

if isempty(plt_objs)
    pxi_time_0 = pxiData(1,obj.pxi.PacketNum);
    crm_time_0 = crmData(1,obj.crm.PacketNum);
    clf;
    subplot(4,1,1)
    title('Left WRBM [Nm]')
    plt_objs = plot((pxiData(:,obj.pxi.PacketNum)- pxi_time_0)/obj.Meta.Rate,pxiData(:,obj.pxi.StrainA));
    xlabel('time [s]')
    ylabel('WRBM [Nm]')
    subplot(4,1,2)
    title('Right WRBM [Nm]')
    plt_objs(2) = plot((pxiData(:,obj.pxi.PacketNum) - pxi_time_0)/obj.Meta.Rate,pxiData(:,obj.pxi.StrainB));
    xlabel('time [s]')
    ylabel('WRBM [Nm]')
    subplot(4,1,3)
    title('Left fold Angle [deg]')
    plt_objs(3) = plot((crmData(:,obj.crm.PacketNum) - crm_time_0)/obj.Meta.Rate,crmData(:,obj.crm.CntA));
    xlabel('time [s]')
    ylabel('Fold Angle [deg]')
    subplot(4,1,4)
    title('Right Fold Angle [deg]')
    plt_objs(4) = plot((crmData(:,obj.crm.PacketNum) - crm_time_0)/obj.Meta.Rate,crmData(:,obj.crm.CntB));
    xlabel('time [s]')
    ylabel('Fold Angle [deg]')
    
else
    plt_objs(1).XData = (pxiData(:,obj.pxi.PacketNum) - pxi_time_0)/obj.Meta.Rate;
    plt_objs(2).XData = (pxiData(:,obj.pxi.PacketNum) - pxi_time_0)/obj.Meta.Rate;
    plt_objs(3).XData = (crmData(:,obj.crm.PacketNum) - crm_time_0)/obj.Meta.Rate;
    plt_objs(4).XData = (crmData(:,obj.crm.PacketNum) - crm_time_0)/obj.Meta.Rate;

    plt_objs(1).YData = pxiData(:,obj.pxi.StrainA);
    plt_objs(2).YData = pxiData(:,obj.pxi.StrainB);
    plt_objs(3).YData = crmData(:,obj.crm.CntA);
    plt_objs(4).YData = crmData(:,obj.crm.CntB);
end
end

