function [model] = logregFitBayesLaplace(X, y, varargin)
% Laplace approximation to posterior for *binary* logistic regression
% We use a N(w | 0, (1/lambda) I) prior
% X is n*d, y is n*1, y(i) = 0 or 1
% A column of 1s will be prepended to X by default

[N D] = size(X);
[lambda, preproc] = process_options(varargin, ...
  'lambda', 1e-5, 'preproc', preprocessorCreate('addOnes', true, 'standardizeX', true));


% First find mode
[model, X] = logregFit(X, y, 'regType', 'L2', 'lambda', lambda, 'preproc', preproc);
wN = model.w;

% Now compute Hessian at mode
if model.preproc.addOnes
  %X = [ones(N, 1) X];
  lambda = lambda*ones(D + 1, 1);
  lambda(1) = 0; % Don't penalize bias term
else
  lambda = lambda*ones(D, 1);
end
[y] = setSupport(y, [-1, 1]);
funObj = @(w) penalizedL2(w, @LogisticLossSimple, lambda, X, y);
[nll, g, H] = funObj(wN); %#ok
VN = inv(H); %H = hessian of neg log lik

model.postType = 'laplace';
model.wN = wN;
model.VN = VN;


end
