function yhat = svmlibPredict(model, Xtest)
% PMTK interface to libsvm
% model is returned by svmlibFit
%%
% Any additional fields added after fitting, must be removed here:
model = rmfield(model, 'C');
model = rmfield(model, 'engine');
%%
n = size(Xtest, 1);
yhat = svmpredict(zeros(n, 1), Xtest, model);
end

