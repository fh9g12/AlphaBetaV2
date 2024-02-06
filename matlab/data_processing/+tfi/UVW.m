function [u,v,w] = UVW(vel,pitch,yaw)

%UVW   Returns u, v and w for Probe velocity, pitch and yaw angle data
%
%   [u, v, w] = UVW(vel, pitch, yaw);
%   Supply velocity, pitch and yaw data (angles in degrees)
%   Returns corresponding u, v and w data
%
%   NOTE: Pitch is actually elevation above u-v plane
%
%See also VELPITCHYAW, TRANSFORMAXES, ALIGNWITHFLOW and READCPFILE

% Convert angles to radians
yaw = yaw * pi/180;
pitch = pitch * pi/180;

% Calculate u, v and w
u = vel .* cos(pitch) .* cos(yaw);
v = vel .* cos(pitch) .* sin(yaw);
w = vel .* sin(pitch);

return
