function [model] = logregFitBayesLaplace(X, y, lambdaVec)
% Laplace approximation to posterior for *binary* logistic regression
% We use a N(w | 0, diag(lambda) ) prior
% We assume a column of 1s has already been added

% We have already preprocessed X so don't do it again
preproc =  preprocessorCreate();
[y] = setSupport(y, [-1, 1]);

% First find mode
[model, X] = logregFit(X, y, 'regType', 'L2', 'lambda', lambdaVec, 'preproc', preproc);
wN = model.w;

% Now find Hessian at mode
funObj = @(w) penalizedL2(w, @LogisticLossSimple, lambda, X, y);
[nll, g, H] = funObj(wN); %#ok
VN = inv(H); %H = hessian of neg log lik

model.postType = 'laplace';
model.wN = wN;
model.VN = VN;

end
