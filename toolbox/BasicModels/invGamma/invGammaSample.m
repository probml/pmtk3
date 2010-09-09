function X = invGammaSample(arg1, arg2, arg3)
% Sample from an inverse gamma distribution with parameters a, b
% X = invGammaSample(model, n); or X = invGammaSample(a, b, n);

% This file is from pmtk3.googlecode.com


if isstruct(arg1)
    model = arg1;
    a = model.a;
    b = model.b;
    if nargin < 2
        n = 1;
    else
        n = arg2;
    end
else
    a = arg1;
    b = arg2;
    if nargin < 3
        n = 1;
    else
        n = arg3;
    end
end


v = 2*a;
s2 = 2*b/v;
X = invchi2rnd(v, s2, n, 1);

end

function xs = invchi2rnd(v, s2, m, n)
% Draw an m*n matrix of inverse chi squared RVs, v = dof, s2=scale
% Gelman p580
xs = v*s2./chi2Sample(struct('dof', v), [m, n]);

end
