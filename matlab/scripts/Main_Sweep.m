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
Model.Meta.Locked = false; % (0/1)

Model.Meta.Job = 'AlphaBetaSweep';
Model.Meta.TestType = 'SteadySweep';
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

val = testscript_input('Take Datum?\n');
if val>0
    Model.Meta.RunType = 'Datum';
    Model.Meta.isDatum = true;
    Model.Meta.ZeroRun = nan;
    fprintf('zeroing serovos...\n')
    Model.ZeroServos();
    pause(2);
    Model.DatumEncoders(-90,'both');
    Model.TakeSample(5);
    Model.Meta.ZeroRun = Model.Meta.RunNumber;
    fprintf('Datum Complete, Run Number: %.0f\n',Model.Meta.RunNumber);
    figure(1);clf;
    Model.plotCalib();
    drawnow;
else
    Model.LoadEncoderDatum();
    Model.Meta.ZeroRun = testscript_input('Zero Run?\n');
end
Model.Meta.RunType = 'Steady';
Model.Meta.isDatum = false;


runLoop = logical(testscript_input('Start Testing? Choose (0 or 1)\n'));
if runLoop == 0
    return
end
alphas = -2:9;
% alphas = [3,4,5,6,7,8,9];
% alphas = [10];
betas = -(0:0.1:1.2)*Model.Meta.FlareAngle;
betas = [betas,fliplr(betas(1:end-1))];
tab = 200;
% betas = -[10,10.5,11]/10*Model.Meta.FlareAngle;
% betas = -[11]/10*Model.Meta.FlareAngle;
% alphas = [0];
% betas = [0];


for a_i = 1:length(alphas)
    Model.MoveServo(1,tab);
    Model.MoveServo(4,tab);
    Model.ohb.moveIncidence(alphas(a_i),2,2,2);
    pause(2);
    curAoA = Model.ohb.readIncidence();
    while isnan(curAoA) || abs(curAoA-alphas(a_i))>0.1
        curAoA = Model.ohb.readIncidence();
        pause(1)
    end
    if a_i == 1
        b_0 = 8;
    else
        b_0 = 1;
    end
    for b_i = b_0:length(betas)
        if b_i == 1
            Model.Meta.isUp = true;
        elseif betas(b_1)>betas(b_i-1)
            Model.Meta.isUp = true;
        else
            Model.Meta.isUp = false;
        end
        Model.ohb.moveYaw(betas(b_i),2,2,2);
        curYaw = Model.ohb.readYaw();
        pause(2);
        while isnan(curYaw) || abs(curYaw-betas(b_i))>0.1
            curYaw = Model.ohb.readYaw();
            pause(1)
        end
        fprintf('Model at AoA %.2f deg, Yaw %.2f...',alphas(a_i),betas(b_i));

        %% take a sample on OC for tunnel conditions
        Model.Meta.Pressure = Model.AmbientPressure;
        Model.Meta.Temperature = Model.AmbientTemp;
        %set pressure on OC
        Model.ohb.setBaro(Model.Meta.Pressure);
        fprintf('Set Baro...')
        pause(0.5);
        fprintf('Take Sample...')
        %% run dynamic test
        Model.ohb.sample(Model.Meta.RunDuration);
        fprintf('...')
        Model.runTest(Model.Meta.RunDuration);
        pause(1);
        fprintf('Get Data...')
        Model.OHBData = OHBData.FromString(Model.ohb.readLastSample());
        Model.saveSample();
        figure(1);clf;
        Model.plotCalib();
        drawnow;
    end
end
Model.ohb.moveIncidence(0,2,2,2);
pause(1);
Model.ohb.moveYaw(0,2,2,2);

