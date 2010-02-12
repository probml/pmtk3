function [yhat, p] = logregPredict(model, X)
% p(i, j) = p(y=j|X(i,:), w)
% yhat - same space as model.ySupport
% A column of 1s is added if this was done at training time

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
        yhat = setSupport(p > 0.5, model.ySupport, [0 1]);
    else
        p = softmax(X*model.w);
        yhat = setSupport(maxidx(p, [], 2), model.ySupport, 1:size(p, 2));
    end
   
end