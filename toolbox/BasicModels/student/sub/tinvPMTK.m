function X = tinvPMTK(p, dof)
%% Replacement for the stats toolbox tinv function
% Inverse of the student T CDF
%%

% This file is from pmtk3.googlecode.com

p       = p(:) - 0.5;
n       = length(p); 
dof     = dof(:);
l       = abs(p) < .25;
u       = ~l;
z       = zeros(n, 1);
zbar    = zeros(n, 1);
absp    = 2*abs(p); 
if any(l)
    zbar(l) = betainvPMTK(absp(l), 0.5, dof(l)/2, 'lower');
end
z(l)    = 1 - zbar(l);
z(u)    = betainvPMTK(absp(u), dof(u)/2, 0.5, 'upper');
if any(u)
    zbar(u) = 1 - z(u);
end
X       = sign(p) .* sqrt(dof .* (zbar./z));
end
