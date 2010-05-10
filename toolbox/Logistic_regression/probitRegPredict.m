function [yhat, p] = probitRegPredict(model, X)
%% Probit Regression Prediction
% p(i) = p(y=1 | X(i,:), model)

if isfield(model, 'preproc')
    X = preprocessorApplyToTest(model.preproc, X);
end
p = probit(X*model.w);
yhat = convertLabelsToPM1(p > 0.5);  




end