classdef CRMMqttReciever < BaseMqttReciever
    properties
        ID = 1;
        PacketNum = 2;
        CntA = 3;
        CntB = 4;
        ch = 5:(5+5);
    end
    methods
        function obj = String2Data(obj,dataStr)
            data = convertStringsToChars(dataStr);
            obj.pData(obj.Idx,obj.ID) = hex2dec(swapBytes(data(1:2)));
            obj.pData(obj.Idx,obj.PacketNum) = hex2dec(swapBytes(data(3:10)));
            obj.pData(obj.Idx,obj.CntA) = hex2dec(swapBytes(data(11:18)));
            obj.pData(obj.Idx,obj.CntB) = hex2dec(swapBytes(data(19:26)));
            idx_0 = 27;
            for i = 1:6
                idx_s = idx_0+(8*(i-1));
                idx_e = idx_0+(8*i)-1;
                obj.pData(obj.Idx,obj.ch(i)) = hex2dec(swapBytes(data(idx_s:idx_e)));
            end
        end
        function write(obj)
            fprintf('ID: %d, Num: %d, CntA: %.2f, CntB: %.2f\n',...
                obj.ID,obj.PacketNum,obj.CntA,obj.CntB);
        end
    end
end

