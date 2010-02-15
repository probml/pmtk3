function [yhat, p] = logregPredict(model, X)
% p(i, j) = p(y=j | X(i,:), model)
% yhat max_j p(i, j) - same space as model.ySupport
% A column of 1s is added if this was done at training time
% This works for both binary and multiclass and kernelized logistic
% regression. 
    n = size(X, 1); 
    if model.includeOffset
        X = [ones(n, 1) X];
    end
    if isfield(model, 'kernelType')
        X = mkUnitVariance(center(X)); % important for kernel performance
        X = kernelBasis(X, model.basis, model.kernelType, model.kernelParam);
    end
    if model.binary
        p = sigmoid(X*model.w);
        yhat = p > 0.5;
        yhat = setSupport(yhat, model.ySupport, [0 1]);
    else
        p = softmax(X*model.w);
        yhat = maxidx(p, [], 2);
        C = size(p, 2); 
        yhat = setSupport(yhat, model.ySupport, 1:C);
    end
end