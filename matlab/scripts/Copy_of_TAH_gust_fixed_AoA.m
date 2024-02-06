close all;fclose all;clear all
%% Required Input Data
Model = ABModelClass(true);
Model.Meta.Rate = 100;
Model.Meta.dataDir = '..\data_TAH\'; % folder to store data in

Model.Meta.RunDuration = 3; % sec
Model.Meta.PreRunPauseDuration = 0.5;
Model.Meta.PostRunPauseDuration = 0.5;
Model.Meta.InterRunPause = 0;

Model.Meta.ModelName = 'TAH_CRM';
Model.Meta.FlareAngle = 10;
Model.Meta.MaxFold = 130;
Model.Meta.Locked = true; % (0/1)

Model.Meta.HasTank = true;
Model.Meta.TankType = 'Liquid';
% Model.Meta.TankType = 'Solid';
Model.Meta.TankSize = 200;
Model.Meta.TankPos = 2;
Model.Meta.TankMass = 75;

Model.Meta.Job = 'TAH_sloshing';
Model.Meta.TestType = 'GustExcitation';

Model.Meta.dataDir = fullfile(Model.Meta.dataDir,date());

AoAs = [4,3,2,1.537];
Vels = [22.5,25,27.5,30];

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
Model.ohb.moveIncidence(0,2,2,2,blocking=true);
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




% OneMC_freq = linspace(2,14,9);
% OneMC_amp = [5,10,15];
% OneMC_repeat = 3;

OneMC_freq = [3.5,9.5];
OneMC_amp = [15];
OneMC_repeat = 3;

% Sine_freq = 1:14;
% Sine_amp = Sine_freq;
% Sine_amp(OneMC_amp>10) = 10;
% Sine_amp = 7*(1 - (Sine_amp/10))+5;
% Sine_amp = [Sine_amp;Sine_amp/2];
% Sine_dur = 10;
% Sine_repeat = 1;

Random_amp = [2,4];
Random_repeat = 2;
Random_dur = 20;

Chirp_freqs = [0,10];
Chirp_amp = [150,100];
Chirp_repeat = 2;
Chirp_time = 45;


% runLoop = logical(testscript_input('Is Wind Speed 15 m/s?\n'));
% if runLoop == 0
%     return
% end
fprintf('Starting Tunnel\n');
Model.ohb.StartAll();
pause(10);

if Vels(1)>10
    for v_i = 10:5:Vels(1)
        Model.ohb.SetWindSpeed(v_i,blocking=true);
    end
end
for v_i = 1:length(Vels)
    Model.ohb.SetWindSpeed(Vels(v_i),blocking=true);
    if v_i == 1
        fprintf('Letting the tunnel settle for 20 seconds...\n');
        pause(20)
    else
        fprintf('Letting the tunnel settle for 15 seconds...\n');
        pause(15);
    end
    Model.ohb.PauseWindSpeedControl();
    %% hunt for correct AoA
    fprintf('Moving to AoA...\n')
    Model.ohb.moveIncidence(AoAs(v_i),2,2,2,blocking=true);
    pause(0.25);
    %% complete 1MC gust Family
    fprintf('Taking Sample For 1MC Gusts...');
    Model.Meta.RunType = 'Tare';
    [rn,d] = Model.TakeSample(3);
    Model.Meta.TareRun = rn;
    Model.Meta.RunType = '1MC';
    for f_i = OneMC_freq
        for amp_i = OneMC_amp
            for rep_i = 1:OneMC_repeat
                Model.Meta.GustFreq = f_i;
                Model.Meta.GustAmplitude = amp_i;
                Model.Meta.GustInverted = false;
                Model.Meta.GustTurb = false;
                Model.Meta.RunDuration = 3.5;
                fprintf('1MC at freq %.2f Hz and Amp %.2f deg...',f_i,amp_i);
                [rn,d] = Model.Take1MCGust(f_i,amp_i,3.5);
            end
        end
    end

%     %% complete Random Turb Family
%     fprintf('Taking Sample For Random Turb...');
%     Model.Meta.RunType = 'Tare';
%     [rn,d] = Model.TakeSample(3);
%     Model.Meta.TareRun = rn;
%     Model.Meta.RunType = 'Turb';
%     for amp_i = Random_amp
%         for rep_i = 1:Random_repeat
%             Model.Meta.GustFreq = nan;
%             Model.Meta.GustAmplitude = amp_i;
%             Model.Meta.GustInverted = false;
%             Model.Meta.GustTurb = true;
%             Model.Meta.RunDuration = Random_dur;
%             fprintf('Turb at Amplitude %.2f deg...',amp_i);
%             [rn,d] = Model.TakeTurbGust(amp_i,Random_dur);
%             pause(2);
%         end
%     end

    %% Complete Sine Sweep
%     fprintf('Taking Sample For SineWaves...');
%     Model.Meta.RunType = 'Tare';
%     [rn,d] = Model.TakeSample(Model.Meta.RunDuration);
%     Model.Meta.TareRun = rn;
%     Model.Meta.RunType = 'StepSine';
%     for f_i = 1:length(Sine_freq)
%         for amp_i = 1:size(Sine_amp,1)
%             for rep_i = 1:Sine_repeat
%                 Model.Meta.GustFreq = Sine_freq(f_i);
%                 Model.Meta.GustAmplitude = Sine_amp(amp_i);
%                 Model.Meta.GustInverted = false;
%                 Model.Meta.GustTurb = false;
%                 Model.Meta.RunDuration = Sine_dur;
%                 fprintf('SineWave at freq %.2f Hz and Amp %.2f deg...',Sine_freq(f_i),Sine_amp(amp_i,f_i));
%                 [rn,d] = Model.TakeSineGust(Sine_amp(amp_i,f_i),Sine_freq(f_i),Sine_dur);
%                 pause(2);
%             end
%         end
%     end

    %% complete AileronChirp Family
%     fprintf('Taking Sample For Aileron Family...');
%     Model.Meta.RunType = 'Tare';
%     [rn,d] = Model.TakeSample(3);
%     Model.Meta.TareRun = rn;
%     Model.Meta.RunType = 'AilChirp';
%     for rep_i = 1:Chirp_repeat
%         Model.Meta.GustFreq = Chirp_freqs(2);
%         Model.Meta.GustAmplitude = amp_i;
%         Model.Meta.GustInverted = false;
%         Model.Meta.GustTurb = false;
%         Model.Meta.RunDuration = Chirp_time;
%         fprintf('Aileron Chirp at Amp %.2f cnts...',amp_i);
%         [rn,d] = Model.TakeChirp('23',Chirp_freqs(1),Chirp_freqs(2),...
%             v2chirpAmp(Vels(v_i)),Chirp_time);
%         pause(2);
%     end
end
Model.ohb.moveIncidence(0,2,2,2);
pause(1)
Model.ohb.SetWindSpeed(0);
Model.Unsubscribe();
pause(20);
Model.ohb.StopAll();

function amp = v2chirpAmp(v)
if v >30
    amp = 100;
elseif v < 22.5
    amp = 150;
else
    p = polyfit([22.5,30],[150,100],1);
    amp = polyval(p,v);
end
end

