function [model, logev] = linregFitBayesGaussPrior(X, y, alpha, beta, addOnes)
% Bayesian inference for a linear regression model with fixed noise
% precision beta and diagonal gaussian prior with precision alpha

[N,d] = size(X);
w0 = zeros(d,1);
alphaVec = alpha*ones(d,1);
if addOnes
  alphaVec(1) = 1e-10; % don't regularize offset term
  % but we require Lam0 to be posdef
end
Lam0 = diag(alphaVec);
s2 = 1/beta;  sigma = sqrt(s2);
[wN, VN] = normalEqnsBayes(X, y, Lam0, w0, sigma);
model.wN = wN;
model.VN = VN;
model.alpha = alpha;
model.beta = beta;

if nargout >= 2
  V0 = diag(1./alphaVec);
  tmp = struct('mu', X*w0, 'Sigma', s2*eye(N) + X*V0*X');
  logev = gaussLogprob(tmp, y);
end
end % end of main function

