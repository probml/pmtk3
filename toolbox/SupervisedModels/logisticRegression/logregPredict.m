function [yhat, p] = logregPredict(model, X)
% Predict response for logistic regression
% p(i, c) = p(y=c | X(i,:), model)
% yhat(i) =  max_c p(i, c) 
%   For binary, this is {0,1} or {-1,1} or {1,2}, same as training
%   For multiclass, this is {1,..,C}, or same as training
%
% Any preprocessing done at training time (e.g., adding 1s,
% standardizing, adding kenrels, etc) is repeated here.

% This file is from pmtk3.googlecode.com

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
    yhat = maxidx(p, [], 2); % yhat in 1:C
    C = size(p, 2); % now in 1:C
    yhat = setSupport(yhat, model.ySupport, 1:C); % restore initial support
end
end
