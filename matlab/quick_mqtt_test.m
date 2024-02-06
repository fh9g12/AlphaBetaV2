clear all
brokerAddress = "tcp://192.168.1.61";
port = 1883;
clientID = "MATLAB";
mqClient = mqttclient(brokerAddress, Port = port, ClientID = clientID);
topicToSub = "CRM/Data";
subscribe(mqClient, topicToSub, Callback = @onData)

% f = 10;
% for i = 1:500
%     pause(0.01)
%     write(mqClient,"CRM/Servo/Set",sprintf('1:%.0f',sin(2*pi*f*i/100)*300+1023));
% end

function onData(topic,dataStr)
%     disp(dataStr)
    data = CRMData();
    data.read(dataStr);
    data.write();
end