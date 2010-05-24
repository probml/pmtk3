%% Simple Test of linregFit()
%
%%
load servo
lossFn = @(y, yhat)mean((y-yhat).^2);
%%
model = linregFit(Xtrain, ytrain, 'preproc', struct('standardizeX', false)); %ols
yhat = linregPredict(model, Xtest);
mse = lossFn(yhat, ytest)
%%
[ytrain, ybar] = centerCols(ytrain);
w = Xtrain \ ytrain;
w0  = ybar - mean(Xtrain)*w;
assert(isequal(w, model.w));
assert(isequal(w0, model.w0));

%% CV over lambda
model = linregFit(Xtrain, ytrain, 'regType', 'L2', 'plotCv', true);
yhat = linregPredict(model, Xtest);
mse = lossFn(yhat, ytest)
set(gca, 'xscale', 'log'); 
%% 
w = linregFitL2QR(mkUnitVariance(centerCols(Xtrain)),centerCols(ytrain), model.lambda); 
assert(isequal(model.w, w));
