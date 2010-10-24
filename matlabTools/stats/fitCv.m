function [model, bestParam, mu, se] = ...
    fitCv(params, fitFn, predictFn, lossFn, X, y,  Nfolds, varargin)
%% Fit a set of models of different complexity and use cross validation to pick the best
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
% bestParam -
% mu(i) - mean loss for params(i,:)
% se(i) - standard error for mu(i,:)
%%

% This file is from pmtk3.googlecode.com

wstate = warning('query', 'MATLAB:nearlySingularMatrix');
warning('off', 'MATLAB:nearlySingularMatrix');

SetDefaultValue(7, 'Nfolds', 5);
[useSErule, doPlot, plotArgs, testFolds, randomizeOrder, params1, params2, ...
  plotWaitBar] = ...
  process_options(varargin , ...
  'useSErule'      , false , ...
  'doPlot'         , false , ...
  'plotArgs'       , {}    , ...
  'testFolds'      , []    , ...
  'randomizeOrder' , false, ...
  'params1'         , [], ...
  'params2'         , [], ...
  'plotWaitBar'     , false);

if isOctave(), plotWaitBar = false; end

% if params is 1 row vector, it is a probably a set of
% single tuning params
if size(params, 1)==1 && size(params, 2) > 2
    %warning('fitCV expects each *row* of Ks to containg tuning params')
    params = params(:);
end
NM = size(params,1);
if NM==1  % single param
    model  = fitFn(X, y, params(1,:));
    bestParam = params(1,:);
    if nargout >= 3
        [mu, se] =  cvEstimate(@(X, y) fitFn(X, y, bestParam), predictFn, lossFn, X, y,  ...
            Nfolds, 'testFolds', testFolds, 'randomizeOrder', randomizeOrder);
    end
    return;
end
mu = zeros(1,NM);
se = zeros(1,NM);
if plotWaitBar, w = waitbar(0,'Cross Validating'); end
for m=1:NM
    param = unwrapCell(params(m, :));
    [mu(m), se(m)] =  cvEstimate(@(X, y) fitFn(X, y, param), predictFn, lossFn, X, y,  Nfolds, 'testFolds', testFolds);
    if plotWaitBar, waitbar(m/NM, w, 'Cross Validating'); end
end
if plotWaitBar, close(w); end
if useSErule
    bestNdx = oneStdErrorRule(mu, se);
else
    bestNdx = argmin(mu);
end
bestParam = unwrapCell(params(bestNdx,:));
model = fitFn(X, y, bestParam);


if doPlot && size(params, 1) > 1;
    if ~isnumeric(bestParam)
        error('Plotting only supported for numerical values');
    end
    singlevals = find(nunique(params) == 1);
    multivals = setdiff(1:numel(bestParam), singlevals);
    ND = max(numel(bestParam)- numel(singlevals), 1);
    switch ND
        case 1
            figure;
            plotCVcurve(params(:, multivals), mu, se, bestParam(multivals), plotArgs{:});
        case 2
            figure;
            plotCVgrid(params(:, multivals), mu, bestParam(multivals), ...
              params1, params2, plotArgs{:});
        otherwise
            error('Plotting is only supported in 1D or 2D');
    end
end
if strcmp(wstate.state, 'on')
    warning('on', 'MATLAB:nearlySingularMatrix');
end
end
