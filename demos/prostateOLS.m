%% OLS  on the prostate data set
% Should match  table 3.3 on p63 of "Elements of statistical
% learning" 2nd edn
% (The OLS results should be identical  - the fact that they are not
% suggests something strange is going on - most likely to do with
% the offset term, which should be unregularized.)
% Used to debug prostateComparison

% This file is from pmtk3.googlecode.com


data = loadData('prostate');
w=[ones(67,1) data.Xtrain] \ data.ytrain

data = loadData('prostate');
w=[ones(67,1) standardize(data.Xtrain)] \ data.ytrain

data = loadData('prostateStnd');
w=[ones(67,1) data.Xtrain] \ data.ytrain  % this one is closest


pp = preprocessorCreate('addOnes', true, 'standardizeX', true);
model = linregFit(data.Xtrain, data.ytrain, 'lambda', 0, ...
  'preproc', pp);
model.w
yhat = linregPredict(model, data.Xtest);
loss = @(yhat, ytest) mean((yhat - ytest).^2); 
mse = loss(yhat, data.ytest)

