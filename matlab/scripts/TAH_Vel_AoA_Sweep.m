close all;fclose all;clear all
%% Required Input Data
Model = ABModelClass();
Model.ohb.openLogFile(); 
Model.Meta.Rate = 100;
Model.Meta.dataDir = '..\data_TAH\'; % folder to store data in

Model.Meta.RunDuration = 3; % sec
Model.Meta.PreRunPauseDuration = 0.5;
Model.Meta.PostRunPauseDuration = 0.5;
Model.Meta.InterRunPause = 0;

Model.Meta.ModelName = 'TAH_CRM';
Model.Meta.FlareAngle = 10;
Model.Meta.MaxFold = 130;
Model.Meta.Locked = true; % (0/1)

Model.Meta.HasTank = false;
Model.Meta.TankType = 'Solid';
% Model.Meta.TankType = 'Liquid';
Model.Meta.TankSize = 0;
Model.Meta.TankPos = 6;
Model.Meta.TankMass = 0;

Model.Meta.Job = 'TAH_sloshing';
Model.Meta.TestType = 'VelAoAMap';
Model.Meta.Comment = 'Strut Only';

Model.Meta.dataDir = fullfile(Model.Meta.dataDir,date());

res = testscript_input('Have you updated Model config? (0 or 1)');
if ~res
    return
end

%% create Model

% val = testscript_input('Take Zero?\n');
Model.LoadEncoderDatum();
% if val>0
Model.Meta.RunType = 'Datum';
Model.Meta.isDatum = true;
Model.Meta.ZeroRun = nan;
fprintf('zeroing serovos...\n')
Model.ZeroServos();
fprintf('Moving to Zero Inc and Yaw...\n')
Model.ohb.moveYaw(0,2,2,2,blocking=true);
Model.ohb.moveIncidence(0,2,2,2,blocking=true);
pause(2);
fprintf('Taking Zero Sample...\n')
Model.TakeSample(5);
Model.Meta.ZeroRun = Model.Meta.RunNumber;
fprintf('Datum Complete, Run Number: %.0f\n',Model.Meta.RunNumber);
figure(1);clf;
Model.plotCalib();
drawnow;
% else
%     Model.Meta.ZeroRun = testscript_input('Zero Run?\n');
% end
Model.Meta.RunType = 'Steady';
Model.Meta.isDatum = false;


% alphas = -3:1.5:9;
alphas = 0;
Vels = 22.5:2.5:30;

% runLoop = logical(testscript_input('Is Wind Speed 15 m/s?\n'));
% if runLoop == 0
%     return
% end
fprintf('Starting Tunnel\n');
Model.ohb.StartAll();
pause(10);

if Vels(1)>10
    for v_i = 10:5:Vels(1)
        Model.ohb.SetWindSpeed(v_i,blocking=true);
    end
end

for v_i = 1:length(Vels)
    Model.ohb.SetWindSpeed(Vels(v_i),blocking=true);
    if v_i == 1
        fprintf('Letting the tunnel settle for 20 seconds...\n');
        pause(20)
    else
        pause(2);
    end
    for a_i = 1:length(alphas)
        fprintf('Vel : %.2f m/s and AoA: %.2f deg...',Vels(v_i),alphas(a_i));
        Model.ohb.moveIncidence(alphas(a_i),2,2,2,blocking=true);
        pause(0.25);
        [~,d] = Model.TakeSample(Model.Meta.RunDuration);
    end
end
Model.ohb.moveIncidence(0,2,2,2);
pause(1)
Model.ohb.SetWindSpeed(0);
Model.Unsubscribe();
pause(15);
Model.ohb.StopAll();

