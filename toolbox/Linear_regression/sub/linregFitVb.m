function [model, logev] = linregFitVb(X, y)
% Variational bayes inference for linear regression
% This is a wrapper to Jan Drugowitsch's code.
% We use the following prior:
%   p(w, beta, alpha) = N(w | 0, (beta diag(alpha))^{-1}) *
%       * IG(beta | a0, b0) * IG(alpha | c0, d0)
% where a0, b0, c0, d0 are set small (vague prior)
% where alpha is a vector of precisions and beta is the noise precision.
% (Thus the model implements ARD) 
% If addOnes=true, we clamp E(alpha(1)) = 10^10 to ensure
% that the first term of w is not regularized.
%
% model is struct  with the following fields
%   wN, VN, aN, bN, cN, dN, expectAlpha, 
%
% logev is the lower bound on the log marginal likelihood


[w, V, invV, logdetV, an, bn, E_a, L] = bayes_linear_fit(X, y); %#ok
  
model.wN  = w; model.VN = V;
model.aN = an; model.bN = bn;
%model.cN = cn; model.dN = dn;
model.expectAlpha = E_a;
logev = L;
end
