function [model, logev] = linregFitBayesJeffreysPrior(X, y, pp) 
% Bayesian inference for a linear regression model with uninformative prior

% This file is from pmtk3.googlecode.com


[model.preproc, X] = preprocessorApplyToTrain(pp, X);
[N,D] = size(X);

% Posterior  on w
%[model.wN, model.VN] = normalEqnsBayes(X, y, 0);
[Q,R] = qr(X,0);
model.wN = R\(Q'*y); % OLS
Rinv = inv(R);
model.VN = Rinv*Rinv';
  
% Posterior on sigma2
%yhat = X*model.wN;;
%s2 = (y-yhat)'*(y-yhat);
s2 = norm(y-X*model.wN)^2;
model.aN = (N-D)/2;
model.bN = s2/2;

if nargout >= 2
  logev = []; % cannot compute this since prior is impropert
end
end % end of main function

