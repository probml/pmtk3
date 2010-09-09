function modelHgivenV = studentCondition(model, v, visValues)
% p(xh|xv=visValues)

% This file is from pmtk3.googlecode.com

mu    = model.mu(:);
Sigma = model.Sigma;
dof   = model.dof;
d = length(mu);
b = visVars;
a = setdiff(1:d, b);
dA = length(a);
dB = length(b);
if isempty(a)
    muAgivenB = []; SigmaAgivenB  = [];
else
    xb = visValues;
    SAA = Sigma(a, a);
    SAB = Sigma(a, b);
    SBB = Sigma(b, b);
    SBBinv = inv(SBB);
    muAgivenB = mu(a) + SAB*SBBinv*(xb-mu(b));
    h = 1/(dof+dB) * (dof + (xb-muB)'*SBBinv*(xb-mu(b)));
    SigmaAgivenB = h*(SAA - SAB*SBBinv*SAB');
end
modelHgivenV.dof = dof + dA;
modelHgivenV.mu = muAgivenB;
modelHgivenV.Sigma = SigmaAgivenB;
end
