function v = wrap(u,N)
% Wrap a vector of indices around a torus
% v = wrap(u,N)
%
% e.g., wrap([-1 0 1 2 3 4], 3)   =   2 3 1 2 3 1

% This file is from pmtk3.googlecode.com


v = mod(u-1,N)+1;       

end
