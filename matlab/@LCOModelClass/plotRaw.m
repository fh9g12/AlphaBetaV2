function [fig_obj,plt_objs] = plotRaw(obj,plt_objs)
arguments
    obj
    plt_objs = []
end
%DRAWDATA Summary of this function goes here
%   Detailed explanation goes here
crmData = obj.crm.Data;
pxiData = obj.pxi.Data;
% if isempty(pxiData) || isempty(crmData)
%     return
% end
fig_obj = figure(1);

if isempty(plt_objs)
    clf;
    subplot(2,1,1)
    title('Strain A')
    plt_objs = plot(pxiData(:,obj.pxi.PacketNum),pxiData(:,obj.pxi.StrainA));
    xlabel('time [s]')
    ylabel('Strain')
%     subplot(4,1,2)
%     title('Z_h')
%     plt_objs(2) = plot(pxiData(:,obj.pxi.PacketNum),pxiData(:,obj.pxi.Z_h));
%     xlabel('time [s]')
%     ylabel('accel')
%     subplot(4,1,3)
%     title('X_h')
%     plt_objs(3) = plot(pxiData(:,obj.pxi.PacketNum),pxiData(:,obj.pxi.X_h));
%     xlabel('time [s]')
%     ylabel('accel')
    subplot(2,1,2)
    title('Encoder A')
    plt_objs(4) = plot(crmData(:,obj.crm.PacketNum),crmData(:,obj.crm.CntA));
    xlabel('time [s]')
    ylabel('Enc Counts')
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

