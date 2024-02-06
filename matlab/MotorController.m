classdef MotorController < matlab.mixin.SetGet
    %MOTORCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % data channels
        EncoderCountTopic = "FlowSurvey/Encoder/Counts"
        MotorPositionTopic = "FlowSurvey/Motor/Position"
        MotorStateTopic = "FlowSurvey/Motor/State"
        MotorSpeedGetTopic = "FlowSurvey/Motor/Speed/Get"
        MotorAccelGetTopic = "FlowSurvey/Motor/Accel/Get"
        AmbientPressureTopic = "Ambient/Pressure"
        AmbientTempTopic = "Ambient/Temperature"

        % command Channels
        MotorTargetTopic = "FlowSurvey/Motor/Target"
        MotorSpeedSetTopic = "FlowSurvey/Motor/Speed/Set"
        MotorAccelSetTopic = "FlowSurvey/Motor/Accel/Set"   
        BrakeEnableTopic = "FlowSurvey/Brake/Enable"
        SoftStopTopic = "FlowSurvey/Brake/Stop"
        HardStopTopic = "FlowSurvey/Brake/HardStop"
        IntervalTopic = "FlowSurvey/Motor/Interval"

        %Encoder Properties
        EncoderGain = -360/1502/1.0483;
        EncoderOffset = -90;
        EncoderCountOffset = 990.4; 
%         StepGain = -52.4587;
%         StepGain = -(1/0.018);
        StepGain = 53.326;
        EncoderMeanAngle;

%         EncoderGain = 360/1502/1.0483;
%         EncoderOffset = -90;
%         EncoderCountOffset = 990.4; 
% %         StepGain = -52.4587;
% %         StepGain = -(1/0.018);
%         StepGain = -53.326;

        IsEncoderPositive = true;
        MotorMaxAngle = 180;
        

        % buffers 
        BufferSize = 10;
        encoderBuffer = [];
        angleBuffer = [];
        encoderIdx = 0;

        positionBuffer  = [];
        positionIdx = 0; 

        % MQTT objects
        mqttClient;
        isSubscribed;

        % get set properties
        Acceleration;
        Speed;
        Position;
        AmbientPressure;
        AmbientTemp;
        State;
    end

    methods
        function set.BufferSize(obj,val)
            obj.BufferSize = val;
            obj.encoderBuffer = zeros(val,1);
            obj.angleBuffer = zeros(val,1);
            obj.encoderIdx = 0;
    
            obj.positionBuffer  = zeros(val,1);
            obj.positionIdx = 0;
        end
        function set.Acceleration(obj,val)
            if obj.mqttClient.Connected
                obj.mqttClient.write(obj.MotorAccelSetTopic,string(val));
            else
                warning("MQTT Client is not connected");
            end
        end
        function set.Speed(obj,val)
            if obj.mqttClient.Connected
                obj.mqttClient.write(obj.MotorSpeedSetTopic,string(val));
            else
                warning("MQTT Client is not connected");
            end
        end
        function val = get.Acceleration(obj)
            if obj.mqttClient.Connected
                val_table = obj.mqttClient.peek(Topic=obj.MotorAccelGetTopic);
                val = str2double(val_table.Data(1));
            else
                warning("MQTT Client is not connected");
            end
        end
        function val = get.Speed(obj)
            if obj.mqttClient.Connected
                val_table = obj.mqttClient.peek(Topic=obj.MotorSpeedGetTopic);
                val = str2double(val_table.Data(1));
            else
                warning("MQTT Client is not connected");
            end
        end
        function val = get.Position(obj)
            if obj.mqttClient.Connected
                val_table = obj.mqttClient.peek(Topic=obj.MotorPositionTopic);
                val = str2double(val_table.Data(1));
            else
                warning("MQTT Client is not connected");
            end
        end
        function val = get.State(obj)
            if obj.mqttClient.Connected
                val_table = obj.mqttClient.peek(Topic=obj.MotorStateTopic);
                val = str2double(val_table.Data(1));
            else
                warning("MQTT Client is not connected");
                val = 0;
            end
        end
        function val = get.AmbientPressure(obj)
            if obj.mqttClient.Connected
                val_table = obj.mqttClient.peek(Topic=obj.AmbientPressureTopic);
                val = str2double(val_table.Data(1));
            else
                warning("MQTT Client is not connected");
            end
        end
        function val = get.AmbientTemp(obj)
            if obj.mqttClient.Connected
                val_table = obj.mqttClient.peek(Topic=obj.AmbientTempTopic);
                val = str2double(val_table.Data(1));
            else
                warning("MQTT Client is not connected");
            end
        end
        function val = get.EncoderMeanAngle(obj)
            buffer = obj.angleBuffer;
            if (max(buffer)-min(buffer))>180
                buffer(buffer<0) = buffer(buffer<0) + 360;
            end
            val = mean(buffer);
            if val>180
                val = val - 360;
            end
        end

    end
    
    methods
        function obj = MotorController(mqttClient)
            %MOTORCONTROLLER Construct an instance of this class
            %   Detailed explanation goes here
            obj.BufferSize = 10;
            obj.mqttClient = mqttClient;
            if obj.mqttClient.Connected
                obj.Subscribe();
            end
        end

            
        function obj = SaveEncoder(obj,data)
            old_idx = obj.encoderIdx;
            obj.encoderIdx = old_idx + 1;
            if obj.encoderIdx > obj.BufferSize
                obj.encoderIdx = 1;
            end
            obj.encoderBuffer(obj.encoderIdx) = str2double(data);
            new_angle = (obj.encoderBuffer(obj.encoderIdx)-obj.EncoderCountOffset)*obj.EncoderGain + obj.EncoderOffset;
            if(new_angle<-180)
                new_angle = new_angle + 360;
            elseif(new_angle>180)
                new_angle = new_angle - 360;
            end
            if new_angle == 0
                new_angle = 1e-3;
            end
            obj.angleBuffer(obj.encoderIdx) = new_angle;
            if old_idx == 0
                 obj.IsEncoderPositive = sign(new_angle) == 1;
            else
                if sign(obj.angleBuffer(old_idx)) ~= sign(new_angle)
                    if max(abs(obj.angleBuffer([old_idx,obj.encoderIdx]))) < 5
                        obj.IsEncoderPositive = sign(new_angle) == 1;
                    end
                end
            end
        end
        function obj = SavePosition(obj,data)
            obj.positionIdx = obj.positionIdx + 1;
            if obj.positionIdx > obj.BufferSize
                obj.positionIdx = 1;
            end
            obj.positionBuffer(obj.positionIdx) = str2double(data);
        end

        function val = isMoving(obj)
            if obj.mqttClient.Connected
                val = obj.State == 3;
            else
                 warning("MQTT Client is not connected");
                 val = false;
            end
        end

        function obj = Unsubscribe(obj)
            if obj.mqttClient.Connected
                obj.mqttClient.unsubscribe(obj.EncoderCountTopic);
                obj.mqttClient.unsubscribe(obj.MotorPositionTopic);
                obj.mqttClient.unsubscribe(obj.MotorStateTopic);
                obj.mqttClient.unsubscribe(obj.MotorSpeedGetTopic);
                obj.mqttClient.unsubscribe(obj.MotorAccelGetTopic);
                obj.mqttClient.unsubscribe(obj.AmbientPressureTopic);
                obj.mqttClient.unsubscribe(obj.AmbientTempTopic);
                obj.isSubscribed = false;
            else
                warning("MQTT Client is not connected");
                obj.isSubscribed = false;
            end
        end

        function SetMessageInterval(obj,interval)
            if obj.mqttClient.Connected
                obj.mqttClient.write(obj.IntervalTopic,string(interval));
            else
                warning("MQTT Client is not connected, Interval not sent...");
            end

        end

        function Move(obj,delta)
            if obj.mqttClient.Connected && obj.isSubscribed
                pos = obj.mqttClient.peek(Topic=obj.MotorPositionTopic);
                new_pos = str2double(pos.Data(1)) + delta;
                obj.mqttClient.write(obj.MotorTargetTopic,string(new_pos));
            else
                warning("MQTT Client is not connected or not Subscribed, Target not sent...");
            end
        end

        function MoveTo(obj,pos)
            if obj.mqttClient.Connected && obj.isSubscribed
                obj.mqttClient.write(obj.MotorTargetTopic,string(pos));
            else
                warning("MQTT Client is not connected or not Subscribed, Target not sent...");
            end
        end

        function MoveToAngle(obj,angle)
            % clip angle request
            angle = min([max([angle,-obj.MotorMaxAngle]),obj.MotorMaxAngle]);

            if obj.mqttClient.Connected && obj.isSubscribed
                current_angle = obj.EncoderMeanAngle;
                if obj.IsEncoderPositive && current_angle < -100
                    current_angle = current_angle + 360;
                elseif ~obj.IsEncoderPositive && current_angle > 100
                    current_angle = current_angle - 360;
                end
                inner_delta = angle-current_angle;
                current_pos = obj.Position;
                target = current_pos + round(inner_delta*obj.StepGain,0);
                obj.mqttClient.write(obj.MotorTargetTopic,string(target));
            else
                warning("MQTT Client is not connected or not Subscribed, Target not sent...");
            end
        end

        function Stop(obj)
            if obj.mqttClient.Connected
                obj.mqttClient.write(obj.HardStopTopic,"1");
            else
                warning("MQTT Client is not connected: Stop Not Sent...")
            end
        end
        
    end
end

