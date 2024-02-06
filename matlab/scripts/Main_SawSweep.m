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
MOdel.Meta.HingeMaterial = 'Metal';
Model.Meta.Locked = false; % (0/1)

Model.Meta.Job = 'AlphaBetaSweep';
Model.Meta.TestType = 'SawSweep';
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
fprintf('zeroing serovos...\n')
pause(1);
Model.ZeroServos();
pause(2)
val = testscript_input('Take Datum?\n');
Model.ZeroServos();
if val>0
    Model.Meta.RunType = 'Datum';
    Model.Meta.isDatum = true;
    Model.Meta.ZeroRun = nan;
    Model.ohb.moveIncidence(0,2,2,2,blocking=true);
    Model.ohb.moveYaw(0,2,2,2,blocking=true);
    Model.LoadEncoderDatum();
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
Model.Meta.RunType = 'TabSweep';
Model.Meta.isDatum = false;


runLoop = logical(testscript_input('Start Testing? Choose (0 or 1)\n'));
if runLoop == 0
    return
end
alphas = [2,3,4,5,6,7,8,9];
% alphas =[5];
% alphas = [3,4,5,6,7,8,9];
% alphas = [10];
betas = -[0,3,5,7,8,9,9.5,10,10.5,11]/10*Model.Meta.FlareAngle;
% betas = -[0,3,5,7,8,9,10,11,12]/10*Model.Meta.FlareAngle;
% betas = -[10,10.5,11]/10*Model.Meta.FlareAngle;
% betas = -[11]/10*Model.Meta.FlareAngle;
% alphas = [0];
% betas = [0];
Model.ZeroServos();
for a_i = 1:length(alphas)
    Model.ohb.moveIncidence(alphas(a_i),2,2,2,blocking=true);
    b_0 = fh.ternary(a_i==1,1,1);
    for b_i = b_0:length(betas)
        Model.ohb.moveYaw(betas(b_i),2,2,2,blocking=true);
        fprintf('Model at AoA %.2f deg, Yaw %.2f...',alphas(a_i),betas(b_i));

        %% take a sample on OC for tunnel conditions
        sample_time = 3;
        Model.Meta.Pressure = Model.AmbientPressure;
        Model.Meta.Temperature = Model.AmbientTemp;
        
        %set pressure on OC
        Model.ohb.setBaro(Model.Meta.Pressure);
        fprintf('Set Baro...')
        pause(1);
        Model.ohb.sample(sample_time);
        fprintf('Take Sample...')
        %% run dynamic test
        sweep_time = 40;
        amplitude = 600;
        Model.BufferSize = ceil(Model.Meta.Rate*(sweep_time+4));
        Model.Meta.datetime = datetime();
        fprintf('Start...')
        Model.Start();
        pause(2);
        Model.SawWave('14',1/sweep_time,amplitude);
        pause(sweep_time + 2)
        Model.Stop();
        fprintf('Get Data...')
        Model.OHBData = OHBData.FromString(Model.ohb.readLastSample());
        Model.saveTimeSeries();
        figure(1);clf;
        Model.plotCalib();
        drawnow;
    end
end
Model.ohb.moveIncidence(0,2,2,2);
pause(1);
Model.ohb.moveYaw(0,2,2,2);

