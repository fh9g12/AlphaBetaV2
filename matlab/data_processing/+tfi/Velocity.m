function vel = Velocity(u,v,w)

%	vel = Velocity(u,v,w);
%
%	Calculates velocity data from u, v and w data


if nargin == 2
   vel = sqrt(u.^2 + v.^2);
elseif nargin == 3
   vel = sqrt(u.^2 + v.^2 + w.^2);
end

return