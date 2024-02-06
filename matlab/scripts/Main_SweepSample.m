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
Model.Meta.Locked = true; % (0/1)

Model.Meta.Job = 'AlphaBetaSweep';
Model.Meta.TestType = 'Sweep';
% d.cfg.TestType = 'BiStable';
% d.cfg.TestType = 'HysteresisLoop';
% d.cfg.TestType = 'Vramp';
% d.cfg.TestType = 'AoAramp';

Model.Meta.dataDir = fullfile(Meta.dataDir,date());

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
if val>0
    Model.Meta.RunType = 'Datum';
    Model.Meta.ZeroRun = nan;
    Model.DatumEncoders(-90,'both');
    Model.TakeSample(5);
    Model.Meta.ZeroRun = Model.Meta.RunNumber;
    fprintf('Datum Complete, Run Number: %.0f\n',Model.Meta.RunNumber);
    figure(2);clf;
    Model.plotRaw();
    drawnow;
else
    Model.Meta.ZeroRun = testscript_input('Zero Run?\n');
end


runLoop = logical(testscript_input('Start Testing? Choose (0 or 1)\n'));
alphas = [0,3];
betas = [3,6,9];
for a_i = 1:length(alphas)
    Model.ohb.moveIncidence(alphas(a_i),2,2,2);
    pause(1);
    curAoA = Model.ohb.readIncidence();
    while isnan(curAoA) || abs(curAoA-alphas(a_i))>0.1
        curAoA = Model.ohb.readIncidence();
        pause(1)
    end
    for b_i = 1:length(betas)
        Model.ohb.moveYaw(betas(b_i),2,2,2);
        curYaw = Model.ohb.readYaw();
        while isnan(curYaw) || abs(curYaw-betas(b_i))>0.1
            curYaw = Model.ohb.readYaw();
            pause(0.5)
        end
        fprintf('Model at AoA %.2f deg, Yaw %.2f... Ready to Test...\n',alphas(a_i),betas(b_i));
        Model.TakeSample(5);
%         figure(2);clf;
%         Model.plotRaw();
%         drawnow;
    end
end




% while true       
%     subCase  = testscript_input('Choose Subcase:\n - datum = 1\n - steady = 2\n - gust = 3\n - final datum = 4\n - Calibration = 5\n');
%     switch(subCase)
%         case 1
%             Model.Meta.RunType = 'Datum';
%             Model.Meta.ZeroRun = nan;
%         case 2
%             Model.Meta.RunType = 'Steady';
%         case 3
%             Model.Meta.RunType = 'Gust';
%         case 4
%             Model.Meta.RunType = 'FinalDatum';
%         case 5
%             Model.Meta.RunType = 'Calibration';
%     end
%     d.cfg.datum = subCase == 1 || subCase == 4;
%     if subCase > 1
%         d.cfg.ZeroRun = testscript_input('Zero Run?\n');
%     end
% 
% 
% %% Select Subcases
% runLoop = logical(testscript_input('Start Testing? Choose (0 or 1)\n'));
% while runLoop
%     fprintf('\nPause for Next Measurement... \n');
%     fprintf('Starting Next Measurement...\n\n');
%     %% Run Test
%     Model.TakeSample(5);
%     %% Load data from tmp DAQ file
%     %% Plots
%     figure(2);clf;
%     Model.plotRaw();
%     drawnow;
%     % for datum runs end after one measurement
%     runLoop = testscript_input('Save data? Choose (0 or 1)\n');
%     %% Prompts
%     if(runLoop)
%         if subCase <=2
%             Model.Meta.CalibMass = testscript_input('Calibration Mass (kg)?\n');
%             Model.Meta.CalibLength = testscript_input('Calibration Moment Arm (Nm)?\n');
%         else
%             Model.Meta.CalibAngle = testscript_input('Calibration Angle (Deg)?\n');
%         end
% 
%         %% enter comments
%         Model.Meta.Comment = input('Enter a Comment\n','s');
% 
%         %% Save data
%         Model.saveData();
%     end
%     runLoop = testscript_input('Continue Testing? Choose (0 or 1)\n');
% 
% end
% %% Finish Test
