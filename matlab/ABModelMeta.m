classdef ABModelMeta < handle
    %ABDATACONVERTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % universal test properties
        ModelName ='';
        Job = '';
        TestType = '';
        Rate = 100;
        dataDir = '';

        % ModelProperties
        FlareAngle = NaN;
        Locked = false;
        TabAngle = NaN;
        MaxFold = NaN;
        SweepAngle = NaN;
        HingeMaterial = 'Metal';
        WingtipLength = 200;
        FreePlay = 0;
        LCO = false;

        %Run Properties
        RunNumber = nan;
        RunType = '';
        isDatum = false;
        isUp = true;
        ZeroRun = nan;
        TareRun = nan;
        datetime;
        RunDuration = 0;
        PreRunPauseDuration = 0;
        PostRunPauseDuration = 0;
        InterRunPause = 0;

        % Tank Info
        HasTank = false;
        TankSize = nan;
        
        TankType = 'Solid';
        TankPos = 1;
        TankMass = nan;

        %Tunnel Properties
        Pressure = nan;
        Temperature = nan;
        Velocity = 0;

        % gust settings
        GustFreq = 0;
        GustAmplitude = 0;
        GustInverted = false;
        GustTurb = false;

        % Calibration Properties
        CalibAngle = nan;
        CalibMass = nan;
        CalibLength = nan;

        % Misc
        Comment = '';
    end

    methods
        function out = ToStruct(obj)
            out = struct(obj);
        end
    end
end

