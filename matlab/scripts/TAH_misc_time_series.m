close all;fclose all;clear all
%% Required Input Data
Model = ABModelClass(true);
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
% Model.Meta.TankType = 'Liquid';
Model.Meta.TankType = 'Solid';
Model.Meta.TankSize = 0;
Model.Meta.TankPos = 3;
Model.Meta.TankMass = 0;

Model.Meta.Job = 'TAH_sloshing';
Model.Meta.TestType = 'GVT';

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
Model.Meta.RunType = 'RightSpar';

res = testscript_input('Ready? (0 or 1)');
if ~res
    return
end
Model.TakeTimeSeries(20);
Model.Unsubscribe();

