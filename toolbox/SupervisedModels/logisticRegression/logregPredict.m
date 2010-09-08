function [yhat, p] = logregPredict(model, X)
% Predict response for logistic regression
% p(i, c) = p(y=c | X(i,:), model)
% yhat(i) =  max_c p(i, c) - same space as model.ySupport
% A column of 1s is added if this was done at training time
% This works for both binary and multiclass and kernelized logistic
% regression.
if ~strcmpi(model.modelType, 'logreg')
  error('can only call this funciton on models of type logreg')
end

if isfield(model, 'preproc')
    [X] = preprocessorApplyToTest(model.preproc, X);
end
if size(model.w,2)==1 % numel(model.ySupport)==2 % model.binary
    p = sigmoid(X*model.w);
    yhat = p > 0.5;  % now in [0 1]
    yhat = setSupport(yhat, model.ySupport, [0 1]); % restore initial support 
else
    p = softmaxPmtk(X*model.w);
    yhat = maxidx(p, [], 2);
    C = size(p, 2); % now in 1:C
    yhat = setSupport(yhat, model.ySupport, 1:C); % restore initial support
end
end