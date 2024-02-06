function ChirpWave(obj,servoStr,f_start,f_end,amp,time)
arguments
    obj
    servoStr
    f_start
    f_end
    amp
    time
end
time = round(time*f_end)/f_end;
obj.mqttClient.write('CRM/Servo/Chirp',sprintf('%s:%.4f:%.4f:%.4f:%.4f',servoStr,f_start,f_end,amp,time))
end

