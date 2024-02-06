close all;fclose all;clear all
%% Required Input Data
Model = LCOModelClass(true);
Model.ohb.openLogFile();
Model.Meta.Rate = 100;
Model.Meta.dataDir = '..\data_LCO\'; % folder to store data in

Model.Meta.RunDuration = 5; % sec
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

Model.Meta.Job = 'Vertical_LCO';
Model.Meta.TestType = 'Vramp';
Model.Meta.dataDir = fullfile(Model.Meta.dataDir,date());

AoA = -3;
ext_freq = 10;
time = 5;
V_0 = 10;

res = testscript_input('Have you updated Model config? (0 or 1)  ');
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


%% get to first data point
Model.ohb.moveYaw(AoA,2,2,2,blocking=true);

%% run loop
while true
    amp = testscript_input('Perturbation Size?   ');
    if amp == 0
        break;
    end
    Model.ohb.PauseWindSpeedControl();
    Model.Meta.RunType = '1MCPerturbation';

    % record Ambient Conditions
    Model.Meta.Pressure = Model.AmbientPressure;
    Model.Meta.Temperature = Model.AmbientTemp;
    Model.ohb.setBaro(Model.Meta.Pressure);
    fprintf('Set Baro...')
    pause(0.25);
    Model.ohb.sample(time-1);
    Model.Meta.GustFreq = ext_freq;
    Model.Meta.GustInverted = false;
    Model.Meta.GustAmplitude = amp;
    Model.Take1MC('2',amp,ext_freq,time);
    Model.mqttClient.flush();
end
Model.Unsubscribe();
