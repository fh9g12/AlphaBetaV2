function [Az,El] = TransformAxesAzEl(Az,El, dAz,dEl,dRoll, Dir)

%TransformAxesAzEl   Returns az,el relative to new axes
%
%   Az is azimuth relative to original (global) axes
%   El is elevation relative to original (global) axes
%
%   dAz is location of new (local) axes relative to original (global) axes
%   dEl is location of new (local) axes relative to original (global) axes
%
%   Dir (optional) is direction of transformation
%      'gl' transforms from global to local axes (default)
%      'lg' transforms from local to global axes
%
%See also VelAzEl2UVW, UVW2VelAzEl


[u,v,w] = VelAzEl2UVW(1,Az,El);			%JM: this returns three column vectors (u,v,w) if Az and El are vectors.

Az = Az * pi/180;
El = El * pi/180;
dAz = dAz * pi/180;
dEl = dEl * pi/180;
dRoll = dRoll * pi/180;

%tAz = [ cos(dAz)    sin(dAz)   0 ;...
%        -sin(dAz)   cos(dAz)   0 ;...
%        0               0              1 ];
%tEl = [ cos(dEl)    0   sin(dEl) ;...
%        0               1   0    ;...
%        -sin(dEl)   0   cos(dEl) ];
%tRoll = [ 1    0            0          ;...
%          0    cos(dRoll)   sin(dRoll) ;...
%          0   -sin(dRoll)   cos(dRoll) ];   
       
%tAzEl = [  cos(dAz)*cos(dEl)    sin(dAz)*cos(dEl)   sin(dEl) ;...
%          -sin(dAz)             cos(dAz)            0        ;...
%          -cos(dAz)*sin(dEl)   -sin(dAz)*sin(dEl)   cos(dEl) ];
    
tAzElRoll = [  cos(dAz)*cos(dEl)                                   sin(dAz)*cos(dEl)                                  sin(dEl)            ;...
              -sin(dAz)*cos(dRoll)-cos(dAz)*sin(dEl)*sin(dRoll)    cos(dAz)*cos(dRoll)-sin(dAz)*sin(dEl)*sin(dRoll)   cos(dEl)*sin(dRoll) ;...
               sin(dAz)*sin(dRoll)-cos(dAz)*sin(dEl)*cos(dRoll)   -cos(dAz)*sin(dRoll)-sin(dAz)*sin(dEl)*cos(dRoll)   cos(dEl)*cos(dRoll) ];
      
vec = [u v w]';									%JM: u, v, w are column vectors, therefore vec is a 3-row matrix,
if ~exist('Dir','var') | strcmp(Dir,'gl')	%JM: with each column in vec being a separate u-v-w vector.
   vec = tAzElRoll*vec;							%JM: Matrix multiplication: the 3 rows in tAzElRoll operate on each u-v-w
else													%JM: vector in vec, producing a final 3-row matrix vec, which is the
   vec = tAzElRoll'*vec;						%JM: transformed velocity vectors.
end

u = vec(1,:)'; v = vec(2,:)'; w = vec(3,:)';		%JM: extract the rows of vec and convert to column vectors once again.

[Vel,Az,El] = UVW2VelAzEl(u,v,w);			%JM: convert the velocity components back to Az and El data

return