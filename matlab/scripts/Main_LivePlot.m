close all;fclose all;clear all

% mqttClient = mqttclient('tcp://192.168.1.61');   
%% Required Input Data
Model = ABModelClass();
Model.Meta.Rate = 100;
Model.Meta.dataDir = '..\data\'; % folder to store data in

Model.Meta.RunDuration = 3; % sec
Model.Meta.PreRunPauseDuration = 0.5;
Model.Meta.PostRunPauseDuration = 0.5;
Model.Meta.InterRunPause = 0;

Model.Meta.ModelName = 'AlphaBeta_V2';
Model.Meta.FlareAngle = 10;
Model.Meta.Locked = true; % (0/1)

Model.Meta.Job = 'StrainGaugeCalibration';
Model.Meta.TestType = 'Calib';
% d.cfg.TestType = 'BiStable';
% d.cfg.TestType = 'HysteresisLoop';
% d.cfg.TestType = 'Vramp';
% d.cfg.TestType = 'AoAramp';

Model.Meta.dataDir = fullfile(Model.Meta.dataDir,date());


Model.Meta.RunType = 'Calibration';
Model.Meta.Velocity = 0;
subCase = 2; % LeftStrainGauge = 1, RightStrainGauge = 2, LeftEncoder = 3, RightEncoder = 4;

switch(subCase)
    case 1
        Model.Meta.TestType = 'LeftStrainGauge';
    case 2
        Model.Meta.TestType = 'RightStrainGauge';
    case 3
        Model.Meta.TestType = 'LeftEncoder';
    case 4
        Model.Meta.TestType = 'RightEncoder';
end

%% create Model
Model.BufferSize = 1000;
Model.ZeroServos();
Model.LoadEncoderDatum();
Model.Start();
pause(1);

[fig,plts] = Model.plotRaw();
while ishandle(fig)  
    Model.plotRaw(plts);
    pause(0.1)
end

% [fig,plts] = Model.plotCalib();
% while ishandle(fig)  
%     Model.plotCalib(plts);
%     pause(0.2)
% end

Model.Stop();

