function SineWave(obj,servoStr,f,A,time)
arguments
    obj
    servoStr
    f
    A
    time
end
time = round(time*f)/f;
obj.mqttClient.write('CRM/Servo/Sine',sprintf('%s:%.6f:%.3f:%.6f',servoStr,f,A,time))
end

