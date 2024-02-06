classdef VanesController
    %VANESCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Vanes wt.GustVane = [wt.GustVane('192.168.1.101',502),wt.GustVane('192.168.1.102',502)];
    end
    
    %% gust methods
    methods
        function gust_timer = OneMinusCosineGust(obj,amp,freq,duration)
            obj.Vanes.setOneMinusCosine(amp,freq,false)
            gust_timer = obj.Vanes.getRunTimer(duration);
        end
        function gust_timer = SineGust(obj,amp,freq,duration)
            obj.Vanes.setSineGust(amp,freq);
            gust_timer = obj.Vanes.getRunTimer(duration);
        end
        function gust_timer = ChirpGust(obj,duration,amplitude,start_freq,end_freq)
            obj.Vanes.setChirp(duration,amplitude,start_freq,end_freq);
            gust_timer = obj.Vanes.getRunTimer(duration);
        end
        function gust_timer = SineGustPhaseShift(obj,amp,freq,duration)
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
            obj.Vanes.setRandomGust(duration,amp);
            gust_timer = obj.Vanes.getRunTimer(duration,delay);
        end
    end
end

