function [u,v,w] = AlignWithFlow(u,v,w);

%AlignWithFlow   Transforms measurements axes such that mean v and w equal zero
%
%   [u, v, w] = AlignWithFlow(u, v, w);
%   Supply u, v and w data
%   Returns transformed u, v and w
%
%See also TRANSFORMAXES, UVW, VELPITCHYAW and READCPFILE


% Convert data to velocity, pitch and yaw
[vel,pitch,yaw] = VelPitchYaw(u,v,w);

% Remove mean pitch and yaw angles
pitch = pitch - mean(pitch);
yaw = yaw - mean(yaw);

% Convert data back to u, v and w
[u,v,w] = UVW(vel,pitch,yaw);

return