function [model] = logregFitLaplaceApprox(X, y, lambda, preproc)
% Laplace approximation to posterior for *binary* logistic regression
% We use a N(w | 0, diag(lambda) ) prior
% We assume a column of 1s has already been added

% This file is from pmtk3.googlecode.com


[y] = setSupport(y, [-1, 1]);

% First find mode - this will add ones for us
[model, X, lambdaVec] = logregFit(X, y, 'regType', 'L2', 'lambda', lambda, 'preproc', preproc);
wN = model.w;
% X has possibly been transformed already

% Now find Hessian at mode
funObj = @(w) penalizedL2(w, @LogisticLossSimple, lambdaVec, X, y);
[nll, g, H] = funObj(wN); %#ok
VN = inv(H); %H = hessian of neg log lik

model.postType = 'laplace';
model.wN = wN;
model.VN = VN;

end
