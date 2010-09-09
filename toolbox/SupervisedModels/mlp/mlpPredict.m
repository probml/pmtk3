function [yhat, py] = mlpPredict(model, X)
% Multi-layer perceptron : prediction
%
% For classification:
% [yhat, py] = mlpPredict(model, X)
% yhat(i) is in same domain as ytrain,
% py(i,k) = p(y=k|X(i,:))
%
% For regression:
% [mu, s2] = mlpPredict(model, X)
% mu(i) = E[y|X(i,:)]
% s2(i) = Var[y|X(i,:)]

% This file is from pmtk3.googlecode.com


if isfield(model, 'preproc')
    [X] = preprocessorApplyToTest(model.preproc, X);
end
[N,D] = size(X); %#ok
    
switch lower(model.method)
  case 'schmidt'
    X1 = [ones(N,1) X];
    mu = MLPregressionPredict_efficient(model.w, X1, model.nHidden);
    switch model.outputType
      case 'regression'
        if nargout >= 2
          sigma2 = repmat(model.sigma2, N, 1);
          % predictive variance is constant since we are using a plug-in approx
        end
        yhat = mu;
        py = sigma2;
      case 'binary'
        yhat = mu>0;
        yhat = setSupport(yhat, model.ySupport, [0 1]);
        if nargout >= 2
          py = sigmoid(mu);
        end
    end
  case 'netlab'
    [mu] = mlpfwd(model.net, X);
    switch model.outputType
      case 'regression'
        yhat = mu;
        if nargout >= 2
          py = repmat(1/model.net.beta, N, 1);
        end
      otherwise
        py = mu;
        [junk, yhat] = max(py,[],2); %#ok
        yhat = setSupport(yhat, model.ySupport);
    end
  otherwise
    error(['method ' method ' not supported'])
end
