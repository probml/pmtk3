function [yhat, v] = linregPredict(model, X)
%% Prediction with linear regression
% yhat(i) = E[y|X(i,:), model]
% v(i) = Var[y|X(i,:), model]
%%

% This file is from pmtk3.googlecode.com

if isfield(model, 'preproc')
    [X] = preprocessorApplyToTest(model.preproc, X);
end
yhat = X*model.w;
if nargout >= 2
  [N] = size(X,1);
  v = model.sigma2*ones(N,1);
end
end
