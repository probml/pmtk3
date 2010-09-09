function [mu, sig2] = linregPredictNetlab(model, X)
% Compute E[y|x] and optionally Var[y|x] for each row of X

% This file is from pmtk3.googlecode.com

[mu, a] = glmfwd(model.netlab, X);
if nargout < 2, return; end
Xtrain = []; ytrain = []; % not needed since we stored the hessian
dummy = []; % not needed
[sig2] = fevbayes(model.netlab, dummy, a, Xtrain, ytrain, X, model.wCov);
%[mu, sig2] = glmevfwd(model.net, model.Xtrain, model.ytrain, X);
end
