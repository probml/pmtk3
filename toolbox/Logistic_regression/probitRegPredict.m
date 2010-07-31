function [yhat, p] = probitRegPredict(model, X)
%% Probit Regression Prediction
% p(i) = p(y=1 | X(i,:), model)
% yhat(i) = MAP label, in original label space
if isfield(model, 'preproc')
    X = preprocessorApplyToTest(model.preproc, X);
end
p = gausscdf(X*model.w);
yhat01 = p>0.5; 
yhat = setSupport(yhat01, model.ySupport, [0 1]);

end