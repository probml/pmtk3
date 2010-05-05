function [yhat, p] = logregPredict(model, X)
%% p(i, j) = p(y=j | X(i,:), model)
% yhat max_j p(i, j) - same space as model.ySupport
% A column of 1s is added if this was done at training time
% This works for both binary and multiclass and kernelized logistic
% regression.
%% Transform the test data in the same way as the training data
if isfield(model, 'preproc')
    [X] = preprocessorApplyToTest(model.preproc, X);
end
%%
if model.binary
    p = sigmoid(X*model.w);
    yhat = p > 0.5;  % now in [0 1]
    yhat = setSupport(yhat, model.ySupport, [0 1]); % restore initial support 
else
    p = softmax(X*model.w);
    yhat = maxidx(p, [], 2);
    C = size(p, 2); % now in 1:C
    yhat = setSupport(yhat, model.ySupport, 1:C); % restore initial support
end
end