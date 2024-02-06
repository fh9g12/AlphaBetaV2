close all;fclose all;clear all
%% Required Input Data
Meta = ABModelMeta();
Meta.Rate = 100;
Meta.dataDir = '..\data\'; % folder to store data in

Meta.RunDuration = 3; % sec
Meta.PreRunPauseDuration = 0.5;
Meta.PostRunPauseDuration = 0.5;
Moter.InterRunPause = 0;

Meta.ModelName = 'AlphaBeta_V2';
Meta.FlareAngle = 10;
Meta.Locked = true; % (0/1)

Meta.Job = 'StrainGaugeCalibration';
Meta.TestType = 'Calib';
% d.cfg.TestType = 'BiStable';
% d.cfg.TestType = 'HysteresisLoop';
% d.cfg.TestType = 'Vramp';
% d.cfg.TestType = 'AoAramp';

Meta.dataDir = fullfile(Meta.dataDir,date());


Meta.RunType = 'Calibration';
Meta.Velocity = 0;
subCase = 1; % LeftStrainGauge = 1, RightStrainGauge = 2, LeftEncoder = 3, RightEncoder = 4;

switch(subCase)
    case 1
        Meta.TestType = 'LeftStrainGauge';
    case 2
        Meta.TestType = 'RightStrainGauge';
    case 3
        Meta.TestType = 'LeftEncoder';
    case 4
        Meta.TestType = 'RightEncoder';
end

CalibMeta = ABCalibMeta();

%% create Model
Model = ABModelClass(Meta,CalibMeta);

%% Select Subcases
runLoop = logical(testscript_input('Start Testing? Choose (0 or 1)\n'));
while runLoop
    fprintf('\nPause for Next Measurement... \n');
    fprintf('Starting Next Measurement...\n\n');
    %% Run Test
    Model.TakeSample(5);
    %% Load data from tmp DAQ file
    %% Plots
    figure(2);clf;
    Model.plotRaw();
    drawnow;
    % for datum runs end after one measurement
    runLoop = testscript_input('Save data? Choose (0 or 1)\n');
    %% Prompts
    if(runLoop)
        if subCase <=2
            Model.Meta.CalibMass = testscript_input('Calibration Mass (kg)?\n');
            Model.Meta.CalibLength = testscript_input('Calibration Moment Arm (Nm)?\n');
        else
            Model.Meta.CalibAngle = testscript_input('Calibration Angle (Deg)?\n');
        end

        %% enter comments
        Model.Meta.Comment = input('Enter a Comment\n','s');

        %% Save data
        Model.saveData();
    end
    runLoop = testscript_input('Continue Testing? Choose (0 or 1)\n');

end
%% Finish Test
