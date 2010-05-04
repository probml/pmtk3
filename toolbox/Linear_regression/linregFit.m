function [model, lambdas, muLoss, seLoss] = linregFit(X, y, varargin)
% Fit a linear regression model
% This takes care of preprocessing the data, computing
% the offset and variance, and calling cross validation (if necessary).
% Subfunctions are used to estimate the regression weights.
%
%% INPUTS:
% regType       ... L1, L2, none, scad
% lambda        ... regularizer (can be a range tuned via cv)
% fitFn         ... fit function  [default depends on regType]
% fitOptions    ... optional  args (a cell array) to fitFn
% preproc       ... a struct, passed to preprocessorApplyToTtrain
% Parameters relating to cross validation
%    nlambdas      ... number of auto-generated regularizer params to cv over
%    nfolds        ... number of folds in the cross validation
%    useSErule     ... if true, pick simplest model within one stderr of best
%    plotCv        ... if true, plot the cv curve or cv grid
%% OUTPUTS:
% model         ... a struct, which you can pass directly to linregPredict
% lambdas       ... values searched over by CV
% muLoss(k)     ... mean loss incurred by lambdas(k)
% seLoss(k)     ... standard error of muLoss(k)
%% process options
args = prepareArgs(varargin); % converts struct args to a cell array
[   regType         ...
    lambda          ...
    fitFn           ...
    fitOptions      ...
    preproc         ...
    nlambdas        ...
    nfolds          ...
    useSErule       ...
    plotCv          ...
    ] = process_options(args , ...
    'regType'       , 'none' , ...
    'lambda'        ,  []    , ...
    'fitFn'         ,  ''    , ...
    'fitOptions'    , {}     , ...
    'preproc'       , []     , ...
    'nlambdas'      , 10     , ...
    'nfolds'        , 5      , ...
    'useSErule'     , false  , ...
    'plotCv'        , false    ...
    );

Xraw = X;
[preproc, X] = preprocessorApplyToTrain(preproc, X);


%% set defaults
if strcmpi(regType, 'none')
    regType = 'l2'; 
    if isempty(lambda)
        lambda = 0;
    end
end

% Pick suitable default optimization method
opts = fitOptions;
if isempty(fitFn)
    switch lower(regType)
        case 'l1'  , fitFn = @(X,y,l) linregFitL1LarsSingleLambda(X,y,l,opts{:});
        case 'l2'  ,  fitFn = @(X,y,l) linregFitL2QR(X,y,l,opts{:});
        case 'scad',  fitFn = @(X,y,l) linregSparseScadFitLLA( X, y, l, opts{:} );
        case 'none', fitFn = @(X,y,l) linregFitL2QR(X,y,l,opts{:});
    end
end

% Choose reasonable range of lambdas to cv over
if isempty(lambda)
    switch lower(regType)
        case 'l1'
            lambdaMax = lambdaMaxLasso(X, centerCols(y));
            lambdas = linspace(1e-5, lambdaMax, nlambdas);
        case {'l2', 'scad'}
            lambdas = 10.^(linspace(-3,2, nlambdas));
    end
else
    lambdas = lambda;
end

if numel(lambdas)==1
    model = fitAndComputeOffset(X, y, lambda, fitFn);
else
    lossFn = @(y, yhat)mean((y-yhat).^2);
    nfolds = min(size(X, 1), nfolds);
    [model, bestLambda, muLoss, seLoss] = ...
        fitCv(lambdas, ...
        @(X, y, param)fitAndComputeOffset(X, y, param, fitFn), ...
        @linregPredict, lossFn, X, y, ...
        nfolds, useSErule, plotCv); %#ok
end

model.preproc  = preproc;
yhat = linregPredict(model, Xraw);
model.sigma2 = var((yhat - y).^2); % MLE of noise variance

end % end of main function

function model = fitAndComputeOffset(X, y, lambda, fitFn)
[y, ybar] = centerCols(y);
w   = fitFn(X, y, lambda);
model.w0  = ybar - mean(X)*w;
model.w   = w;
model.lambda = lambda;
end

