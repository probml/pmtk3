function [model, logev] = linregFitBayesGaussPrior(X, y, alpha, beta, pp)
% Bayesian inference for a linear regression model with fixed noise
% precision beta and diagonal gaussian prior with precision alpha

% This file is from pmtk3.googlecode.com


[model.preproc, X] = preprocessorApplyToTrain(pp, X);
[N,d] = size(X);
w0 = zeros(d,1);
alphaVec = alpha*ones(d,1);
if pp.addOnes
  alphaVec(1) = 1e-10; % don't regularize offset term
  % but we require Lam0 to be posdef
end
Lam0 = diag(alphaVec);
s2 = 1/beta;  sigma = sqrt(s2);
[wN, VN] = normalEqnsBayes(X, y, Lam0, w0, sigma);
model.wN = wN;
model.VN = VN;
model.beta = beta;

% for diagnostics
model.alpha = alpha;

if nargout >= 2
  V0 = diag(1./alphaVec);
  mu =  X*w0; Sigma =  s2*eye(N) + X*V0*X';
  logev = gaussLogprob(mu, Sigma, y(:)');
end
end % end of main function

