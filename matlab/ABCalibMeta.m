classdef ABCalibMeta < handle
    %ABDATACONVERTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % universal test properties

        %% TAH AND AB RIG
%         StrainAGain = 10656.4664231403;
%         StrainAOffset = -0.461254182273666;
%         StrainBGain = 11341.7078049643;
%         StrainBOffset = -1.13430499625685;
%         ServoGain = ones(6,1);
%         ServoOffset = zeros(6,1);
%         ServoZeroPos = [1020,950,1005,955,890,1090];

        %% LCO Rig
        StrainAGain = 15975.4133772666;
        StrainAOffset = 0.926276852666007+1.85;
        StrainBGain = 15975.4133772666;
        StrainBOffset = 0.926276852666007+1.85;
        ServoGain = ones(6,1);
        ServoOffset = zeros(6,1);
        ServoZeroPos = [1240,1100,1005,955,890,1090];

        %% calib
%         StrainAGain = 1;
%         StrainAOffset = 0;
%         StrainBGain = 1;
%         StrainBOffset = 0;
%         

        EncAGain = -360/(2^12);
        EncAOffset = 0;
        EncBGain = 360/(2^12);
        EncBOffset = 0;

        
    end

    methods
        function out = ToStruct(obj)
            out = struct(obj);
        end
    end
end

