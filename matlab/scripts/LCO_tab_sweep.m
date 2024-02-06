close all;fclose all;clear all
%% Required Input Data
Model = LCOModelClass(true);
Model.ohb.openLogFile();
Model.Meta.Rate = 100;
Model.Meta.dataDir = '..\data_LCO\'; % folder to store data in

Model.Meta.RunDuration = 5; % sec
Model.Meta.PreRunPauseDuration = 0.5;
Model.Meta.PostRunPauseDuration = 0.5;
Model.Meta.InterRunPause = 0;

Model.Meta.ModelName = 'Vertical_LCO';
Model.Meta.FlareAngle = 15;
Model.Meta.SweepAngle = -20;
Model.Meta.MaxFold = 130;
Model.Meta.Locked = false; % (0/1)
Model.Meta.HingeMaterial = 'Metal';
Model.Meta.WingtipLength = 200;
Model.Meta.FreePlay = 0;

Model.Meta.Job = 'Vertical_LCO';
Model.Meta.TestType = 'Vramp';
Model.Meta.dataDir = fullfile(Model.Meta.dataDir,date());

tabs = -500:100:500;
% Vels = 10:2.5:20;
Vels = 15:2.5:25;
Vels = 10:2.5:22.5;
Vels = [10,12,14,16,17];

res = testscript_input('Have you updated Model config? (0 or 1)');
if ~res
    return
end

%% create Model
Model.LoadEncoderDatum();
[rn,~] = Model.TakeDatum();
Model.Meta.RunType = 'Steady';
Model.Meta.isDatum = false;
Model.Meta.ZeroRun = rn;

fprintf('Starting Tunnel\n');
Model.ohb.moveYaw(-3,2,2,2,blocking=true);
Model.ohb.StartAll();
pause(10);

for v_i = 5:5:Vels(1)
    Model.ohb.SetWindSpeed(v_i,blocking=true);
end

for v_i = 1:length(Vels)
    Model.ohb.SetWindSpeed(Vels(v_i),blocking=true);
    if v_i == 1
        fprintf('Letting the tunnel settle for 15 seconds...\n');
        pause(15)
    else
        fprintf('Letting the tunnel settle for 10 seconds...\n');
        pause(10);
    end
    Model.ohb.PauseWindSpeedControl();
    for t_i = 1:length(tabs)
        Model.MoveServo(1,tabs(t_i));
        Model.Meta.TabAngle = tabs(t_i);
        pause(0.25);
        fprintf('Taking Sample @ %.2f m/s, tab %.0f cnts...',Vels(v_i),tabs(t_i));
        [rn,d] = Model.TakeSample(4);
    end
end
Model.Unsubscribe();
Model.ohb.SetWindSpeed(0,blocking=true);
Model.ZeroServos;
Model.ohb.StopAll();

