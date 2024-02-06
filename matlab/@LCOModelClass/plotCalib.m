function [fig_obj,plt_objs] = plotCalib(obj,plt_objs)
arguments
    obj;
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
    subplot(2,1,1)
    title('Strain A')
    plt_objs = plot(pxiData(:,obj.pxi.PacketNum)-pxi_time_0,pxiData(:,obj.pxi.StrainA));
    xlabel('time [s]')
    ylabel('Strain')
%     subplot(4,1,2)
%     title('Z_h')
%     plt_objs(2) = plot(pxiData(:,obj.pxi.PacketNum)-pxi_time_0,pxiData(:,obj.pxi.Z_h));
%     xlabel('time [s]')
%     ylabel('accel')
%     subplot(4,1,3)
%     title('X_h')
%     plt_objs(3) = plot(pxiData(:,obj.pxi.PacketNum)-pxi_time_0,pxiData(:,obj.pxi.X_h));
%     xlabel('time [s]')
%     ylabel('accel')
    subplot(2,1,2)
    title('Encoder A')
    plt_objs(4) = plot(crmData(:,obj.crm.PacketNum)-crm_time_0,crmData(:,obj.crm.CntA));
    xlabel('time [s]')
    ylabel('Enc')
else
    plt_objs(1).XData = pxiData(:,obj.pxi.PacketNum);
%     plt_objs(2).XData = pxiData(:,obj.pxi.PacketNum);
%     plt_objs(3).XData = pxiData(:,obj.pxi.PacketNum);
    plt_objs(2).XData = crmData(:,obj.crm.PacketNum);

    plt_objs(1).YData = pxiData(:,obj.pxi.StrainA);
%     plt_objs(2).YData = pxiData(:,obj.pxi.Z_h);
%     plt_objs(3).YData = pxiData(:,obj.pxi.X_h);
    plt_objs(2).YData = crmData(:,obj.crm.CntA);
end
end

