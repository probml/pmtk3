function [yhat, post] = generativeClassifierPredict(logprobFn, model, Xtest)
% Return the predicted class labels
%% Inputs
%
% logprobFn - a function handle: logp = logprobFn(classConditionals{c}, Xtest)
% model     - a struct returned by generativeClassifierFit()
% Xtest         - Xtest(i, :) is the ith case
%
%% Outputs
%
% yhat      - yhat(i) is the predicted class label for Xtest(i, :)
% post      - post(i, j) is the posterior probability that Xtest(i, :) belongs
%             to class j.
%
%%

% This file is from pmtk3.googlecode.com

n = size(Xtest, 1);
nclasses = model.nclasses;
classConditionals = model.classConditionals;
L = zeros(n, nclasses);
logpy = log(model.prior.T + eps);
for c=1:nclasses
    L(:, c) = logprobFn(classConditionals{c}, Xtest) + logpy(c);
end
yhat = maxidx(L, [], 2);
yhat = setSupport(yhat, model.support);
if nargout == 2
    post = exp(normalizeLogspace(L));
end


end
