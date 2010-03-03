function [yhat, v] = linregPredict(model, X)
% Linear regression
% yhat(i) = E[y|X(i,:), model]
% v(i) = Var[y|X(i,:), model]

% Transform the test data in the same way as the training data
if isfield(model, 'Xmu')
  [X] = center(X, model.Xmu);
end
if isfield(model, 'Xstnd')
  [X] = mkUnitVariance(X, model.Xstnd);
end

yhat = X*model.w;
% apply offset term
if isfield(model, 'w0')
    yhat = yhat + model.w0;
end
if nargout >= 2
  [N] = size(X,1);
  v = model.sigma2*ones(N,1);
end

end