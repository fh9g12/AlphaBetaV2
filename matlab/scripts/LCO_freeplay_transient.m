close all;fclose all;clear all
%% Required Input Data
Model = LCOModelClass(true);
Model.ohb.openLogFile();
Model.Meta.Rate = 100;
Model.Meta.dataDir = '..\data_LCO\'; % folder to store data in

Model.Meta.RunDuration = 3; % sec
Model.Meta.PreRunPauseDuration = 0.5;
Model.Meta.PostRunPauseDuration = 0.5;
Model.Meta.InterRunPause = 0;

Model.Meta.ModelName = 'Vertical_LCO';
Model.Meta.FlareAngle = 15;
Model.Meta.MaxFold = 130;
Model.Meta.Locked = false; % (0/1)
Model.Meta.HingeMaterial = 'Metal';
Model.Meta.WingtipLength = 200;
Model.Meta.FreePlay = 70;

Model.Meta.Job = 'Vertical_LCO_Freeplay';
Model.Meta.TestType = 'Perturbations';
Model.Meta.dataDir = fullfile(Model.Meta.dataDir,date());

AoA = -3;

res = testscript_input('Have you updated Model config?   ');
if ~res
    return
end

%% take Datum
Model.LoadEncoderDatum();
val = testscript_input('Take Zero?  ');
if val>0
    [RunNumber,d] = Model.TakeDatum('time',5);
    Model.Meta.ZeroRun = RunNumber;
else
    Model.Meta.ZeroRun = testscript_input('Zero Run?  ');
end
Model.Meta.RunType = 'Steady';
Model.Meta.isDatum = false;


%% set into test postion
Model.ohb.moveYaw(AoA,2,2,2,blocking=true);

while true
    %% perform adhoc test
    res = testscript_input('Ready? (0 or 1)');
    if ~res
        break
    end
    % take tare
    Model.Meta.RunType = 'Tare';
    Model.Meta.TareRun = nan;
    [rn,~] = Model.TakeSample(5);
    Model.Meta.RunType = 'Transient';
    Model.Meta.TareRun = rn;
    t = testscript_input('Transient Length?');
    Model.TakeTimeSeries(t);
end
Model.Unsubscribe();

