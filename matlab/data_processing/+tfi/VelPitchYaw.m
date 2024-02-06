function [vel,pitch,yaw] = VelPitchYaw(u,v,w)

%VelPitchYaw  Returns velocity, pitch and yaw angles for Probe u, v and w data
%
%   [vel, pitch, yaw] = VelPitchYaw(u, v, w);
%   Supply u, v and w data
%   Returns corresponding velocity, pitch and yaw data (angles in degrees)
%   
%   NOTE: Pitch is actually elevation above u-v plane
%
%See also UVW, TRANSFORMAXES, ALIGNWITHFLOW and READCPFILE


% Create zero arrays
vel = zeros(length(u),1);
pitch = zeros(length(u),1);
yaw = zeros(length(u),1);

% Calculate velocity
vel = sqrt(u.^2 + v.^2 + w.^2);

% Find velocity not equal to zero points
velNotZeroPoints = find(vel);

% Calculate azimuth and elevation angles
pitch(velNotZeroPoints) = asin(w(velNotZeroPoints)./vel(velNotZeroPoints));
yaw(velNotZeroPoints) = atan2(v(velNotZeroPoints),u(velNotZeroPoints));

% Convert angles to degrees
pitch = pitch * 180/pi;
yaw = yaw * 180/pi;

return
