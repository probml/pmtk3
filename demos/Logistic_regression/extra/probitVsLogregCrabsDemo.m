%% Compare logistic regresion and probit regression on the crabs dataset
%
%%
load crabs
%% Logistic regression
modelLR = logregFit(Xtrain, ytrain); 
yhat = logregPredict(modelLR, Xtest); 
nerrsLR = sum(yhat ~= ytest)
%% Probit Regression
modelProbit = probitRegFitEm(Xtrain, ytrain);
yhat = probitRegPredict(modelProbit, Xtest);
nerrsProbit = sum(yhat ~= ytest)
