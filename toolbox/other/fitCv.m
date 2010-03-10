function [model, bestParam, mu, se] = fitCv(params, fitFn, predictFn, lossFn, X, y,  Nfolds, useSErule, doPlot)
% Fit a set of models of different complexity and use cross validation to pick the best
%
% Inputs:
% params is a matrix where each row corresponds to a different tuning parameter
%  eg models = [lambda1(1) lambda2(1); ...
%               lambda1(N) lambda2(N)]
%  You can use the crossProduct function to create this if necessary
% model = fitFn(Xtrain, ytrain, param), param = vector of tuning parameters
% yhat = predictFn(model, Xtest)
% L = lossFn(yhat, ytest), should return a column vector of errors
% X is N*D design matrix
% y is N*1
% Nfolds is number of CV folds; set to N to get LOOCV
% useSErule: if true,  pick simplest model within 1 standard error
%  of best; we assume models (rows of params) are ordered from simplest to most
%  complex.
%
% Outputs
% model  - best model
% bestNdx - index of best model
% mu(i) - mean loss for params(i,:)
% se(i) - standard error for mu(i,:)

if nargin < 8, useSErule = false; end
if nargin < 9, doPlot = false; end
% if params is 1 row vector, it is a probbaly a set of
% single tuning params
if size(params, 1)==1
    %warning('fitCV expects each *row* of Ks to containg tuning params')
    params = params(:);
end
NM = size(params,1);

if NM==1 && nargout<=2 % single param
   model  = fitFn(X, y, params(1,:));
   bestParam = params(1,:);
   return;
   % if you ask for mu, you still need to run cvEstimate
   % to estimate te gneralization error for this 1 model
end

mu = zeros(1,NM);
se = zeros(1,NM);
w = waitbar(0,'Cross Validating'); % works in Octave
for m=1:NM
    param = unwrapCell(params(m, :));
    [mu(m), se(m)] =  cvEstimate(@(X, y) fitFn(X, y, param), predictFn, lossFn, X, y,  Nfolds);
    waitbar(m/NM, w, 'Cross Validating');
end
if ~isOctave(), close(w); end
if useSErule
    bestNdx = oneStdErrorRule(mu, se);
else
    bestNdx = argmin(mu);
end
bestParam = unwrapCell(params(bestNdx,:));
model = fitFn(X, y, bestParam);

if doPlot
   if ~isnumeric(bestParam)
      error('Plotting only supported for numerical values');  
   end
   switch numel(bestParam)
       case 1
           plotCVcurve(params, mu, se, bestParam);
       case 2
           plotCVgrid(params, mu, bestParam); 
       otherwise
            error('Plotting is only supported in 1D or 2D'); 
   end
   
   
end


end