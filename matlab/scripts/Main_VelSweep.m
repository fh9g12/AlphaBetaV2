close all;fclose all;clear all
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
Model.Meta.MaxFold = 130;
Model.Meta.Locked = false; % (0/1)

Model.Meta.Job = 'AlphaBetaSweep';
Model.Meta.TestType = 'Velocity Sweep';

Model.Meta.dataDir = fullfile(Model.Meta.dataDir,date());

res = testscript_input('Have you updated Model config? (0 or 1)');
if ~res
    return
end

%% create Model

val = testscript_input('Take Zero?\n');
Model.LoadEncoderDatum();
if val>0
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
else
    Model.Meta.ZeroRun = testscript_input('Zero Run?\n');
end
Model.Meta.RunType = 'Steady';
Model.Meta.isDatum = false;


alphas = [2,5,8];
tabs = [0,100,200];
Model.ohb.moveYaw(0,2,2,2,blocking=true);

while true
    runLoop = logical(testscript_input('Continue Testing? Choose (0 or 1)\n'));
    if runLoop == 0
        break
    end
    for a_i = 1:length(alphas)
        Model.ohb.moveIncidence(alphas(a_i),2,2,2,blocking=true);
        for t_i = 1:length(tabs)
            Model.StraightMove(1,tabs(t_i),0.5);
            pause(1);
            Model.StraightMove(4,tabs(t_i),0.5);
            pause(1);
            Model.Meta.TabAngle = tabs(t_i);
            fprintf('Model at AoA %.2f deg, Yaw %.2f deg...',alphas(a_i),0);
            [~,d] = Model.TakeSample(4);
        end
    end
end
Model.ohb.moveIncidence(0,2,2,2);
pause(1);
Model.ohb.moveYaw(0,2,2,2);
Model.Unsubscribe();

