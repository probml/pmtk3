function [model, logev] = linregFitVb(X, y, pp, useARD)
% Variational bayes inference for linear regression
% This is a wrapper to Jan Drugowitsch's code.
% We use the following prior:
%   p(w, beta, alpha) = N(w | 0, (beta diag(alpha))^{-1}) *
%       * IG(beta | a0, b0) * prod_j IG(alpha(j) | c0, d0)
% where a0, b0, c0, d0 are set small (vague prior),
% alpha is a vector of precisions and beta is the noise precision.
% (If useARD=false, alpha is a scalar) 
%
% model is struct  with the following fields
%   wN, VN, aN, bN, cN, dN, expectAlpha, 
%
% logev is the lower bound on the log marginal likelihood

% This file is from pmtk3.googlecode.com


[model.preproc, X] = preprocessorApplyToTrain(pp, X);
if ~useARD
  [w, V, invV, logdetV, an, bn, E_a, L] = bayes_linear_fit(X, y); %#ok
else
  [w, V, invV, logdetV, an, bn, E_a, L] =   bayes_linear_fit_ard(X, y); %#ok
end

model.wN  = w; model.VN = V;
model.aN = an; model.bN = bn;
%model.cN = cn; model.dN = dn;
model.expectAlpha = E_a;
logev = L;
end
