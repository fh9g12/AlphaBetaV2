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
Model.Meta.FlareAngle = 17.5;
Model.Meta.MaxFold = 90;
Model.Meta.Locked = false; % (0/1)
Model.Meta.HingeMaterial = 'Metal';

Model.Meta.Job = 'AlphaBetaSweep';
Model.Meta.TestType = 'BoundarySurvey';
% d.cfg.TestType = 'BiStable';
% d.cfg.TestType = 'HysteresisLoop';
% d.cfg.TestType = 'Vramp';
% d.cfg.TestType = 'AoAramp';

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

tab = 200;
Model.StraightMove(1,tab,1);
Model.StraightMove(4,tab,1);

while true
    while true
        val = testscript_input('Move Servo? (nan break loop)\n');
        if isnan(val)
            break
        end
        tab = val;
        Model.StraightMove(1,tab,1);
    end
    Model.Meta.TabAngle = tab;
    runLoop = logical(testscript_input('Continue Testing? Choose (0 or 1)\n'));
    if runLoop == 0
        break;
    end

    % take tunnel conditions sample
    Model.Meta.RunType = 'SteadyDatum';
    [rn,~] = Model.TakeSample(3);

    %start dynmaic measurements
    Model.Meta.TareRun = rn;
    Model.Meta.RunType = '1MCPerturbation';
    Model.Meta.GustFreq = 3;
    Model.Meta.GustInverted = true;

%     Model.Meta.GustFreq = testscript_input('Frequency?\n');
    Model.Meta.GustAmplitude = testscript_input('Perturabtion Size?\n');
    while Model.Meta.GustAmplitude ~= 0
        fprintf('BeginMove...Amp %.0f...',Model.Meta.GustAmplitude);
        Model.BufferSize = Model.Meta.Rate*7;
        Model.Start();
        pause(0.5);
        Model.OneMinusCosine('1',Model.Meta.GustFreq,Model.Meta.GustAmplitude);
        if Model.Meta.GustAmplitude<0
            Model.Meta.GustInverted = true;
            Model.Meta.GustAmplitude = -Model.Meta.GustAmplitude;
        else
            Model.Meta.GustInverted = false;
        end
        pause(5)
        Model.Stop();
        fprintf('SaveData...\n');
        [RunNumber,d] = Model.saveTimeSeries();
        Model.plotCalib();
        drawnow;
        Model.Meta.GustAmplitude = testscript_input('Perturabtion Size?\n');
%         Model.Meta.GustFreq = testscript_input('Frequency?\n');
    end
end
Model.ohb.moveIncidence(0,2,2,2);
pause(1);
Model.ohb.moveYaw(0,2,2,2);
Model.Unsubscribe();

