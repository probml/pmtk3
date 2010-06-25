function [yhat, p] = logregPredictVb(model, X)
% Variational bayes prediction for logistic regression
% This is a wrapper to Jan Drugowitsch's code.

p = bayes_logit_post(X, model.wN, model.VN, model.invVN);
yhat = p > 0.5;  % now in [0 1]
yhat = setSupport(yhat, model.ySupport, [0 1]);
end
