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
Model.Meta.SweepAngle = -20;
Model.Meta.MaxFold = 130;
Model.Meta.Locked = false; % (0/1)
Model.Meta.HingeMaterial = 'Metal';
Model.Meta.WingtipLength = 200;
Model.Meta.FreePlay = 0;

Model.Meta.Job = 'Vertical_LCO';
Model.Meta.TestType = 'Vramp';
Model.Meta.dataDir = fullfile(Model.Meta.dataDir,date());

V_auto = [10:2:18,19,20,21];
tab = -400;
AoA = -3;
Ail_ext = 800;
FWT_ext = 800;
ext_freq = 10;
pause_time = 1;

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
% set tab angle
Model.MoveServo(1,tab);
Model.Meta.TabAngle = tab;
Model.ohb.moveYaw(AoA,2,2,2,blocking=true);
%get tunnel up to speed
fprintf('Starting Tunnel\n');
Model.ohb.StartAll();
pause(10);
for v_i = 5:5:V_auto(1)
    Model.ohb.SetWindSpeed(v_i,blocking=true);
end
Model.ohb.SetWindSpeed(V_auto(1),blocking=true);
% fprintf('Letting the tunnel settle for 20 seconds...\n');
% pause(20)
for v_i = 1:length(V_auto)
    Model.ohb.SetWindSpeed(V_auto(v_i),blocking=true);
    fprintf('Letting Tunnel Settle...\n')
    pause(15);
    Model.Meta.RunType = 'Steady';
    Model.Meta.TareRun = nan;
    Model.TakeTimeSeries(5,'Save',false,'PlotData',true,'TakeOCSample',true);
    Model.mqttClient.flush();
    Model.Meta.LCO = false;
    [RunNumber,d] = Model.saveTimeSeries();
    Model.Meta.TareRun = RunNumber;
    % complete Aileron Excitation
    Model.Meta.RunType = '1MCPerturbation';
    Model.Meta.GustFreq = ext_freq;
    Model.Meta.GustInverted = false;
    Model.Meta.GustAmplitude = Ail_ext;
    for i = 1:3
        Model.Take1MC('2',Ail_ext,ext_freq,5);
        pause(pause_time)
    end
    pause(pause_time);
    % complete Wingtip Excitation
    Model.Meta.RunType = '1MCPerturbation';
    Model.Meta.GustFreq = ext_freq;
    Model.Meta.GustInverted = false;
    Model.Meta.GustAmplitude = FWT_ext;
    for i = 1:3
        pause(pause_time)
        Model.Take1MC('1',FWT_ext,ext_freq,5);
    end
end

%% switching to manual control
V_i = testscript_input(sprintf('Next WindSpeed?   '));
Model.ohb.SetWindSpeed(V_i,blocking=true);
while true
    runLoop = logical(testscript_input('Continue Testing?  '));
    if runLoop == 0
        break;
    end
    Model.ohb.PauseWindSpeedControl();
    Model.Meta.RunType = 'Steady';
    Model.Meta.TareRun = nan;
    Model.TakeTimeSeries(5,'Save',false,'PlotData',true,'TakeOCSample',true);
    isSteady = logical(testscript_input('Is Steady?  '));
    Model.mqttClient.flush();
    if isSteady
        Model.Meta.LCO = false;
        [RunNumber,d] = Model.saveTimeSeries();
        Model.Meta.TareRun = RunNumber;
        isExcite = testscript_input_empty('Excite Modes?',1);
        if isExcite > 0
            % complete Aileron Excitation
            Model.Meta.RunType = '1MCPerturbation';
            Model.Meta.GustFreq = ext_freq;
            Model.Meta.GustInverted = false;
            Model.Meta.GustAmplitude = Ail_ext;
            for i = 1:3
                Model.Take1MC('2',Ail_ext,ext_freq,4.5);
                pause(isExcite)
            end
            pause(isExcite);
            % complete Wingtip Excitation
            Model.Meta.RunType = '1MCPerturbation';
            Model.Meta.GustFreq = ext_freq;
            Model.Meta.GustInverted = false;
            Model.Meta.GustAmplitude = FWT_ext;
            for i = 1:3
                pause(isExcite)
                Model.Take1MC('1',FWT_ext,ext_freq,4.5);
            end
        end
    else
        Model.Meta.LCO = true;
        [RunNumber,d] = Model.saveTimeSeries();
    end
    peak_mom = max(abs(d.wingroot_strain));
    V_new = testscript_input(sprintf('\nPeak WRBM = %.2f Nm, Next WindSpeed?   ',peak_mom));
    if (V_new ~= 0) && abs(V_new - V_i)>5
        V_new = testscript_input(sprintf('Current V is %.2f m/s, Next WindSpeed?   ',V_i));
    end
    V_i = V_new;
    Model.ohb.SetWindSpeed(V_new,blocking=true);
    Model.mqttClient.flush();
    if V_i == 0
        break
    end
end

Model.ohb.SetWindSpeed(0,blocking=true);
Model.ohb.moveYaw(0,2,2,2,blocking=true);
Model.Unsubscribe();
Model.ohb.StopAll();
