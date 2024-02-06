mqttClient = mqttclient("tcp://192.168.1.61");
obj = ABModelClass(ABModelMeta(),ABCalibMeta(),mqttClient);

buff = 1000;
obj.BufferSize = buff;

figure(1);
subplot(4,1,1)
p1 = plot(zeros(buff,1));
subplot(4,1,2)
p2 = plot(zeros(buff,1));
subplot(4,1,3)
p3 = plot(zeros(buff,1));
subplot(4,1,4)
p4 = plot(zeros(buff,1));



% while true
%     pause(0.5)
%     crm = obj.crm.Data;
%     crmIdx = obj.crm.Idx;
%     pxi = obj.pxi.Data;
%     pxiIdx = obj.pxi.Idx;
%     if pxiIdx == length(pxi)  
%         pxiIdx = 1:length(pxi);
%     else
%         pxiIdx = [(pxiIdx+1):length(pxi),1:pxiIdx];
%     end
%     if crmIdx == length(crm)  
%         crmIdx = 1:length(crm);
%     else
%         crmIdx = [(crmIdx+1):length(crm),1:crmIdx];
%     end
% 
%     p1.YData = [pxi(pxiIdx).StrainA];
%     p2.YData = [pxi(pxiIdx).StrainB];
%     p3.YData = [crm(crmIdx).CntA];
%     p4.YData = [crm(crmIdx).CntB];
% end

%% make plot
obj.runTest(2);
crmData = obj.crm.Data;
pxiData = obj.pxi.Data;

obj.plotRaw();