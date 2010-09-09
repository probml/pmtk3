%% Compare logistic regresion and probit regression on the crabs dataset
%
%%

% This file is from pmtk3.googlecode.com

setSeed(0);
loadData('crabs');
%% Logistic regression
modelLR = logregFit(Xtrain, ytrain); 
yhat = logregPredict(modelLR, Xtest); 
nerrsLR = sum(yhat ~= ytest)
%% Probit Regression
modelProbit = probitRegFit(Xtrain, ytrain);
yhat = probitRegPredict(modelProbit, Xtest);
nerrsProbit = sum(yhat ~= ytest)
