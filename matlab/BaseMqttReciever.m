classdef BaseMqttReciever < handle & matlab.mixin.SetGet
    %WTBASEDATA Summary of this class goes here
    %   Detailed explanation goes here

    properties
        pData;
        Data;
        Cols = 4;

        BufferSize = 100;
        Idx = 0;
        BufferFull = false;
        Enable = false;
    end

    methods
        
        function obj = BaseMqttReciever(obj)
            obj.CleanBuffer();
        end
        function val = get.Data(obj)
            if obj.Idx == obj.BufferSize || ~obj.BufferFull
                dIdx = 1:obj.Idx;
            else
                dIdx = [(obj.Idx+1):obj.BufferSize,1:obj.Idx];
            end
            val = obj.pData(dIdx,:);
        end
        function set.BufferSize(obj,val)
            obj.BufferSize = val;
            obj.CleanBuffer();
        end
        function CleanBuffer(obj)
            obj.pData = nan(obj.BufferSize,4);
            obj.Idx = 0;
            obj.BufferFull = false;
        end

        function read(obj,dataStr,resetBuffer)
            arguments
                obj
                dataStr
                resetBuffer = false;
            end
            if obj.Enable
                if resetBuffer
                    obj.CleanBuffer()
                end
                obj.Idx = obj.Idx + 1;
                if obj.Idx > obj.BufferSize
                    obj.Idx = 1;
                    obj.BufferFull = true;
                end
                obj.String2Data(dataStr);
            end
        end

        function String2Data(obj,dataStr)

        end
    end
end

