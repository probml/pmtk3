function S = chi2Sample(arg1, arg2)
% Sample n samples from a chi^2 distribution dof degress of freedom
% S = chi2Sample(dof, n) OR S = chi2Sample(model, n)

% This file is from pmtk3.googlecode.com

if isstruct(arg1)
    model = arg1;
    dof   = model.dof;
else
    dof = arg1;
end
if nargin < 2
    n = 1;
else
    n = arg2;
end

if ~isequal(length(dof), n)
    dof = repmat(dof, n);
end
S = 2.*randgamma(dof./2);
end
