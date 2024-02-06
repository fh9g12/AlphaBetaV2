function  MoveServo(obj,ServoNum,pos)
%MOVESERVO Summary of this function goes here
%   Detailed explanation goes here
if abs(pos)>800
    warning('Move limited to 800 counts')
    pos = sign(pos)*800;
end
target = pos + obj.CalibMeta.ServoZeroPos(ServoNum);
obj.mqttClient.write("CRM/Servo/Set",sprintf('%.0f:%.0f',ServoNum,target));
end

