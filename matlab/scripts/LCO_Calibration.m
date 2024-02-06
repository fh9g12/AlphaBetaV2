close all;fclose all;clear all
%% Required Input Data
Model = ABModelClass(true);
Model.ohb.openLogFile();
Meta = ABModelMeta();
Model.Meta.Rate = 100;
Model.Meta.dataDir = '..\data_LCO\'; % folder to store data in

Meta.RunDuration = 3; % sec
Meta.PreRunPauseDuration = 0.5;
Meta.PostRunPauseDuration = 0.5;
Moter.InterRunPause = 0;

odel.Meta.RunDuration = 3; % sec
Model.Meta.PreRunPauseDuration = 0.5;
Model.Meta.PostRunPauseDuration = 0.5;
Model.Meta.InterRunPause = 0;

Model.Meta.ModelName = 'LCO';
Model.Meta.FlareAngle = 10;
Model.Meta.MaxFold = 130;
Model.Meta.Locked = true; % (0/1)


Model.Meta.Job = 'StrainGaugeCalibration';
Model.Meta.TestType = 'Calib';

Model.Meta.dataDir = fullfile(Model.Meta.dataDir,date());


Model.Meta.RunType = 'Calibration';
Model.Meta.Velocity = 0;
subCase = 1; % LeftStrainGauge = 1, RightStrainGauge = 2, LeftEncoder = 3, RightEncoder = 4;

switch(subCase)
    case 1
        Meta.TestType = 'RightStrainGauge';
    case 2
        Meta.TestType = 'LeftEncoder';
    case 3
        Meta.TestType = 'RightEncoder';
end

%% Select Subcases
runLoop = logical(testscript_input('Start Testing? Choose (0 or 1)\n'));
while runLoop
    fprintf('\nPause for Next Measurement... \n');
    fprintf('Starting Next Measurement...\n\n');
    %% Run Test
    Model.TakeSample(5,'Save',false,'PlotData',false);
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
        [RunNumber,d] = Model.saveSample();
    end
    runLoop = testscript_input('Continue Testing? Choose (0 or 1)\n');

end
%% Finish Test
