function [yhat, v] = linregPredict(model, X)
% Prediction with linear regression
% yhat(i) = E[y|X(i,:), model]
% v(i) = Var[y|X(i,:), model]

% Transform the test data in the same way as the training data
if isfield(model, 'preproc')
  [X] = preprocessorApplyToTest(model.preproc, X);
else
  if isfield(model, 'Xmu')
    X = centerCols(X, model.Xmu);
  end
  if isfield(model, 'Xstnd')
    X = mkUnitVariance(X, model.Xstnd);
  end
  if isfield(model, 'Xscale')
    X = rescaleData(X, model.Xscale(1), model.Xscale(2));
  end
  if isfield(model, 'kernelFn')
    X = model.kernelFn(X, model.basis, model.kernelParam);
  end
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