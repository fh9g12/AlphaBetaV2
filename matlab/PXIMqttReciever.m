classdef PXIMqttReciever < BaseMqttReciever
    properties
        PacketNum = 1;
        Time = 2;
        StrainA = 3;
        StrainB = 4;
        GustVaneAngle = 5;
%         Z_h = 6;
%         X_h = 7;
    end
    methods
        function obj = String2Data(obj,dataStr)
            data = convertStringsToChars(dataStr);
            obj.pData(obj.Idx,obj.PacketNum) = hex2dec(data(1:8));
            obj.pData(obj.Idx,obj.Time) = hex2num(data(9:24));
            obj.pData(obj.Idx,obj.StrainA) = hex2num(data(25:40));
            obj.pData(obj.Idx,obj.StrainB) = hex2num(data(41:56));
            obj.pData(obj.Idx,obj.GustVaneAngle) = hexsingle2num(data(57:72));
%             obj.pData(obj.Idx,obj.Z_h) = hexsingle2num(data(73:88));
%             obj.pData(obj.Idx,obj.X_h) = hexsingle2num(data(89:104));
        end
        function write(obj)
            fprintf('Num: %d, StrainA: %.2f, StrainB: %.2f\n',...
                obj.PacketNum,obj.StrainA,obj.StrainB);
        end
    end
end

