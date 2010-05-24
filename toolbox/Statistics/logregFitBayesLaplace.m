function [model] = logregFitBayesLaplace(X, y, lambda)
% Laplace approximation to posterior for *binary* logistic regression
% We use a N(w | 0, (1/lambda) I) prior
% X is n*d, y is d*1, y(i) = 0 or 1
% Do not add a column of 1s

[N D] = size(X);

% First find mode
[model] = logregFit(X, y, 'regType', 'L2', 'lambda', lambda);
wN = model.w;
includeOffset = (length(wN) == D+1);

% Now compute Hessian at mode
if includeOffset
  X = [ones(N, 1) X];
  lambda = lambda*ones(D + 1, 1);
  lambda(1) = 0; % Don't penalize bias term
else
  lambda = lambda*ones(D, 1);
end
[y] = setSupport(y, [-1, 1]);
funObj = @(w) penalizedL2(w, @LogisticLossSimple, lambda, X, y);
[nll, g, H] = funObj(wN); %#ok
VN = inv(H); %H = hessian of neg log lik

model.post = structure(wN, VN);

end
