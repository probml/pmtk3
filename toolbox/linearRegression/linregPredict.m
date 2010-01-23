
function [yhat, v] = linregPredict(model, X)
% Linear regression
% adds a column of 1s if this was done at training time
% yhat(i) = E[y|X(i,:), model]
% v(i) = Var[y|X(i,:), model]

[N,D] = size(X);
if model.includeOffset
   X = [ones(N,1) X];
end
yhat = X*model.w;
v = model.sigma2*ones(N,1);
