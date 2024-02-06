close all;fclose all;clear all

% mqttClient = mqttclient('tcp://192.168.1.61');   
%% Required Input Data
Model = LCOModelClass();
Model.Meta.Rate = 100;
Model.Meta.dataDir = '..\data\'; % folder to store data in

Model.Meta.RunDuration = 3; % sec
Model.Meta.PreRunPauseDuration = 0.5;
Model.Meta.PostRunPauseDuration = 0.5;
Model.Meta.InterRunPause = 0;

%% create Model
Model.BufferSize = 1000;
Model.ZeroServos();
Model.LoadEncoderDatum();
Model.Start();
pause(1);

% [fig,plts] = Model.plotRaw();
% while ishandle(fig)  
%     Model.plotRaw(plts);
%     pause(0.1)
% end
% 
[fig,plts] = Model.plotCalib();
while ishandle(fig)  
    Model.plotCalib(plts);
    pause(0.2)
end

Model.Stop();
Model.Unsubscribe();

