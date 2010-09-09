function yhat = svmlibLinearPredict(model, Xtest)
% PMTK interface to svm liblinear
% model is returned by svmlibLinearFit
%%

% This file is from pmtk3.googlecode.com

n = size(Xtest, 1);
evalc('yhat = libLinearPredict(zeros(n, 1), sparse(Xtest), model)');
end

