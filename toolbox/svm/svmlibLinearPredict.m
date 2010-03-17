function yhat = svmlibLinearPredict(model, Xtest)
% PMTK interface to svm liblinear
% model is returned by svmlibLinearFit
%%
% Any additional fields added after fitting, must be removed here:
model = rmfield(model, 'C');
model = rmfield(model, 'engine');
%%
n = size(Xtest, 1);
yhat = predict(zeros(n, 1), sparse(Xtest), model);
end

