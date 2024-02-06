function StraightMove(obj,servo,endPos,time)
%STRAIGHTMOVE Summary of this function goes here
%   Detailed explanation goes here
arguments
    obj ABModelClass
    servo
    endPos
    time
end
if servo>length(obj.CalibMeta.ServoZeroPos)
    error('%.0f in an invalid servo number\n',servo)
end
endPos = endPos + obj.CalibMeta.ServoZeroPos(servo);
obj.mqttClient.write('CRM/Servo/Line',sprintf('%.0f:%.6f:%.3f:%.6f',servo,endPos,time))
end

