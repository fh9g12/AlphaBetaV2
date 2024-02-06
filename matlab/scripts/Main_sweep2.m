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


runLoop = logical(testscript_input('Start Testing? Choose (0 or 1)\n'));
if runLoop == 0
    return
end
alphas = unique([-3:9,-1.5]);
% alphas = [5,5];
% alphas = 7:10;
% alphas = unique([3:10,6.5,7.5,8.5]);
% alphas = 0:9;
% alphas = -1.5;
% alphas = -2;
% alphas = [3,4,5,6,7,8,9];
% alphas = [10];
tab = 200;
% betas = -[10,10.5,11]/10*Model.Meta.FlareAngle;
% betas = -[11]/10*Model.Meta.FlareAngle;
% alphas = [0];
% betas = [0];

beta_start = 0;
beta_inc = -0.1*Model.Meta.FlareAngle;

for a_i = 1:length(alphas)
    Model.MoveServo(1,tab);
    Model.MoveServo(4,tab);
    Model.Meta.TabAngle = tab;
    Model.ohb.moveIncidence(alphas(a_i),2,2,2,blocking=true);

    Model.Meta.isUp = true;
    Nbeta = 1;
    folds_up = [];
    betas = [beta_start];
    while length(betas)<2 || Model.Meta.isUp
        Model.ohb.moveYaw(betas(end),2,2,2,blocking=true);
        fprintf('Model at AoA %.2f deg, Yaw %.2f...',alphas(a_i),betas(end));
        [~,d] = Model.TakeSample(Model.Meta.RunDuration);
        folds_up(Nbeta) = d.right_enc.mean;
        if length(betas)>1 && abs(folds_up(Nbeta))>90 && abs(folds_up(Nbeta) - folds_up(Nbeta-1))<0.25
            % on the stop so switch direction
            Model.Meta.isUp = false;
        elseif abs(betas(Nbeta))>=Model.Meta.FlareAngle*2
            Model.Meta.isUp = false;
        else
            betas(Nbeta+1) = betas(Nbeta) + beta_inc;
            Nbeta = Nbeta + 1;
        end
    end
    fprintf('Going Down ...\n')
    betas_down = [betas(Nbeta)];
    Nbeta = 1;
    folds_down = [];

    while length(betas)<2 || ~Model.Meta.isUp
        Model.ohb.moveYaw(betas_down(end),2,2,2,blocking=true);
        fprintf('Model at AoA %.2f deg, Yaw %.2f...',alphas(a_i),betas_down(end));
        [~,d] = Model.TakeSample(Model.Meta.RunDuration);
        folds_down(Nbeta) = d.right_enc.mean;
        if length(betas_down)>1 && abs(folds_down(Nbeta))>90 && abs(folds_down(Nbeta) - folds_down(Nbeta-1))<0.25
            betas_down(Nbeta+1) = betas_down(Nbeta) - beta_inc;
            Nbeta = Nbeta + 1;
        elseif abs(folds_down(Nbeta))>90
            betas_down(Nbeta+1) = betas_down(Nbeta) - beta_inc;
            Nbeta = Nbeta + 1;
        else
            bbs = linspace(betas_down(Nbeta),0,4);
            bbs = bbs(2:end);
            for b_i = 1:length(bbs)
                Model.ohb.moveYaw(bbs(b_i),2,2,2,blocking=true);
                fprintf('Model at AoA %.2f deg, Yaw %.2f...',alphas(a_i),bbs(b_i));
                [~,d] = Model.TakeSample(Model.Meta.RunDuration);
                folds_down(Nbeta+b_i) = d.right_enc.mean;
                betas_down(Nbeta+b_i) = bbs(b_i);
            end
            Model.Meta.isUp = true;
        end
    end
    figure(3);clf;hold on
    plot(betas,folds_up);
    plot(betas_down,folds_down);
end
Model.ohb.moveIncidence(0,2,2,2);
pause(1);
Model.ohb.moveYaw(0,2,2,2);
Model.Unsubscribe();

