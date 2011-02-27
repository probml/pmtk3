%% Test the oneVsRestClassifFit function 
% by comparing its results to liblinear's built in procedure. 
% PMTKslow
% PMTKneedsOptimToolbox quadprog
%%

% This file is from pmtk3.googlecode.com

requireOptimToolbox
loadData('soy'); %C=3, N=307, D=35
setSeed(0);
[X, Y] = shuffleRows(X, Y);
Xtrain = X(1:250, :); ytrain = Y(1:250);
Xtest  = X(251:end,:); ytest = Y(251:end); 
%% Fit using oneVsRestClassifFit as a wrapper to binary svm
fitfn  = @(X, y)svmFit(X,y,'kernel', @kernelLinear,...
                'fitFn', @svmQPclassifFit, 'standardizeX', false);
predFn = @(model, X)argout(2, @svmQPclassifPredict, model, X); % use second arg, f as score
model  = oneVsRestClassifFit(Xtrain, ytrain, fitfn); 
yhat   = oneVsRestClassifPredict(model, Xtest, predFn); 
nerrors = sum(yhat ~= ytest)
%% Compare the results to liblinear
model2 = svmFit(Xtrain, ytrain, 'kernel', 'linear',...,
               'fitFn', @svmlibLinearFit, 'standardizeX', false);
yhat2  = svmPredict(model2, Xtest);
nerrors = sum(yhat ~= ytest)
%%
