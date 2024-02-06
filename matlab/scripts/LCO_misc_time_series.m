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
Model.Meta.SweepAngle = -20;
Model.Meta.MaxFold = 130;
Model.Meta.Locked = false; % (0/1)
Model.Meta.HingeMaterial = 'Metal';
Model.Meta.WingtipLength = 200;
Model.Meta.FreePlay = 0;

Model.Meta.Job = 'Vertical_LCO';
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
% Model.ohb.moveIncidence(0,2,2,2,blocking=true);
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
Model.Meta.RunType = 'GVT_Wingtip';


%% set into test postion
tab = -00;
Model.ohb.moveYaw(-3,2,2,2,blocking=true);
Model.MoveServo(1,tab);
Model.Meta.TabAngle = tab;

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

