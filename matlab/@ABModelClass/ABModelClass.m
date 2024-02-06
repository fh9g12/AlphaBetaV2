classdef ABModelClass < matlab.mixin.SetGet
    %ABMODELCLASS Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Meta ABModelMeta = ABModelMeta();
        CalibMeta ABCalibMeta = ABCalibMeta();
        OHBData OHBData = OHBData();
        % MQTT objects

        isSubscribed = false;
        hasGustVanes = false;

        % data channels
        ServoSetTopic = "CRM/Servo/Set";
        CRMDataTopic = "CRM/Data";
        PXIDataTopic = "CRM/PXI/Data";
        useRecieverTopic = "CRM/useReciever";
        AmbientPressureTopic = "Ambient/Pressure";
        AmbientTempTopic = "Ambient/Temperature";
        AmbientIntervalTopic = "Ambient/Interval";

        % other controls
        Vanes wt.GustVane;
        ohb wt.OHBControl;
        mqttClient icomm.mqtt.Client;


        % data buffers
        crm = CRMMqttReciever();
        pxi = PXIMqttReciever();
        BufferSize = 100;

        % get set properties
        AmbientPressure;
        AmbientTemp;
        ohb_string;

    end

    %% gust methods

    methods
        function gust_timer = OneMinusCosineGust(obj,amp,freq,duration)
            if ~obj.hasGustVanes
                error('Gust Vanes not setup')
            end
            obj.Vanes.setOneMinusCosine(amp,freq,false)
            gust_timer = obj.Vanes.getRunTimer(duration);
        end
        function gust_timer = SineGust(obj,amp,freq,duration)
            if ~obj.hasGustVanes
                error('Gust Vanes not setup')
            end
            obj.Vanes.setSineGust(amp,freq);
            gust_timer = obj.Vanes.getRunTimer(duration);
        end
        function gust_timer = ChirpGust(obj,duration,amplitude,start_freq,end_freq)
            if ~obj.hasGustVanes
                error('Gust Vanes not setup')
            end
            obj.Vanes.setChirp(duration,amplitude,start_freq,end_freq);
            gust_timer = obj.Vanes.getRunTimer(duration);
        end
        function gust_timer = SineGustPhaseShift(obj,amp,freq,duration)
            if ~obj.hasGustVanes
                error('Gust Vanes not setup')
            end
            obj.Vanes(1).setSineGust(amp,freq);
            obj.Vanes(2).setSineGust(amp,freq);
            gust_timer = obj.Vanes.getRunTimer(duration,1/freq/2);
        end
        function gust_timer = TurbGust(obj,amp,duration,delay)
            arguments
                obj
                amp
                duration
                delay = 0
            end
            if ~obj.hasGustVanes
                error('Gust Vanes not setup')
            end
            obj.Vanes.setRandomGust(duration,amp);
            gust_timer = obj.Vanes.getRunTimer(duration,delay);
        end
    end
    %% other methods
    methods
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
        function Start(obj)
            obj.pxi.Enable = false;
            obj.crm.Enable = false;
            obj.mqttClient.flush();
            obj.Subscribe();
            obj.CleanBuffers();
            obj.pxi.Enable = true;
            obj.crm.Enable = true;
        end
        function Stop(obj)
            obj.pxi.Enable = false;
            obj.crm.Enable = false;
        end

        function set.BufferSize(obj,val)
            obj.pxi.BufferSize = val;
            obj.crm.BufferSize = val;
        end

        function CleanBuffers(obj)
            obj.crm.CleanBuffer();
            obj.pxi.CleanBuffer();
        end
        function obj = ABModelClass(hasGustVanes)
            arguments
                hasGustVanes = false;
            end
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here

            obj.mqttClient = mqttclient("tcp://192.168.1.61");
            obj.mqttClient.subscribe(obj.AmbientPressureTopic);
            obj.mqttClient.subscribe(obj.AmbientTempTopic);
            obj.mqttClient.write(obj.AmbientIntervalTopic,"100");
            obj.hasGustVanes = hasGustVanes;
            obj.ohb = wt.OHBControl();
            obj.ohb.connect('192.168.1.61');
            if hasGustVanes
                obj.Vanes = [wt.GustVane('192.168.1.101',502),wt.GustVane('192.168.1.102',502)];
            end
        end

        function obj = Unsubscribe(obj)
            if obj.isSubscribed
                if obj.mqttClient.Connected
                    obj.mqttClient.unsubscribe(Topic=obj.CRMDataTopic);
                    obj.mqttClient.unsubscribe(Topic=obj.PXIDataTopic);
                    obj.isSubscribed = false;
                else
                    warning("MQTT Client is not connected");
                    obj.isSubscribed = false;
                end
            end
        end
        function obj = Subscribe(obj)
            if ~obj.isSubscribed
                if obj.mqttClient.Connected
                    obj.mqttClient.subscribe(obj.CRMDataTopic,Callback=@(t,data)obj.crm.read(data));
                    obj.mqttClient.subscribe(obj.PXIDataTopic,Callback=@(t,data)obj.pxi.read(data));
                    obj.isSubscribed = true;
                else
                    warning("MQTT Client is not connected");
                    obj.isSubscribed = false;
                end
            end
        end
    end
end

