function X = invGammaSample(model, n)
% Sample from an inverse gamma distribution 
% with parameters model.a, model.b.
% *** requires stats toolbox ***
requireStatsToolbox
a = model.a;
b = model.b;
v = 2*a;
s2 = 2*b/v;
X = invchi2rnd(v, s2, n, 1);

end

function xs = invchi2rnd(v, s2, m, n)
% Draw an m*n matrix of inverse chi squared RVs, v = dof, s2=scale
% Gelman p580
xs = v*s2./chi2rnd(v, m, n);

end