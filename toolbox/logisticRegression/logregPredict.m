function [yhat, p] = logregPredict(model, X)
% p(i, j) = p(y=j | X(i,:), model)
% yhat max_j p(i, j) - same space as model.ySupport
% A column of 1s is added if this was done at training time
% This works for both binary and multiclass and kernelized logistic
% regression.

if isfield(model, 'Xmu')
    X = center(X, model.Xmu);
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
if model.includeOffset
    X = [ones(size(X, 1), 1) X];
end
if model.binary
    p = sigmoid(X*model.w);
    yhat = p > 0.5;  % in [0 1]
    yhat = setSupport(yhat, model.ySupport, [0 1]); 
else
    p = softmax(X*model.w);
    yhat = maxidx(p, [], 2);
    C = size(p, 2);
    yhat = setSupport(yhat, model.ySupport, 1:C);
end
end