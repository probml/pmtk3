function [model, logev] = logregFitVb(X, y, pp, useARD)
% Variational bayes inference for logistic regression
% This is a wrapper to Jan Drugowitsch's code.
% We use the following prior:
%   p(w, alpha) = N(w | 0, diag(alpha)^{-1}  ) * prod_j IG(alpha(j) | a0, b0)
% where a0, b0 are set small (vague prior)
% where alpha is a vector of precisions.
% (If useARD = false, alpha is a scalar) 
%
% model is struct  with the following fields
%   wN, VN,  expectAlpha, 
%
% logev is the lower bound on the log marginal likelihood


y = setSupport(y, [-1 1]);
[model.preproc, X] = preprocessorApplyToTrain(pp, X);

if ~useARD
  [w, V, invV, logdetV, E_a, L] = bayes_logit_fit(X, y); %#ok
else
  [w, V, invV, logdetV, E_a, L] = bayes_logit_fit_ard(X, y); %#ok
end

model.wN  = w; model.VN = V; model.invVN = invV;
model.expectAlpha = E_a;
logev = L;
end
