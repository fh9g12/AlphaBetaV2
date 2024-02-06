function SawWave(obj,servoStr,f,A)
%ONEMINUSCOSINE Summary of this function goes here
%   Detailed explanation goes here
obj.mqttClient.write('CRM/Servo/Saw',sprintf('%s:%.6f:%.3f',servoStr,f,A))
end
