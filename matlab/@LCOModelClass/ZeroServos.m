function ZeroServos(obj)
%ZEROSERVOS Summary of this function goes here
%   Detailed explanation goes here
for i = 1:length(obj.CalibMeta.ServoZeroPos)
    obj.MoveServo(i,0);
end
end

