function [model, lambdas, muLoss, seLoss] = logregFit(X, y, varargin)
% Fit a logistic regression model, (supports multiclass)
%% INPUTS: (specified as name value pairs)
% regType       ... 'L1' or 'L2'
% nclasses      ... the number of output classes
% lambda        ... regularizer (can be a range tuned via cv)
%                   each ROW should contain the combination of desired
%                   lambdas
% fitFn         ... regType dependent, e.g. @L1GeneralProjection
%                   @(objective, winit, lambda, fitOptions, X, y);
% 
% fitOptions    ... optional fitMethod args (a struct)
% preproc       ... a struct, passed to preprocessorApplyToTtrain
%% cross validation related inputs
% nlambdas      ... number of auto-generated regularizer params to cv over
% nfolds        ... number of folds in the cross validation
% useSErule     ... if true, pick simplest model within one stderr of best
% plotCv        ... if true, plot the cv curve 
%% OUTPUTS:
% model         ... a struct, which you can pass directly to logregPredict
% lambdas       ... values searched over by CV (best value stored in
%                   model.lambda)
% muLoss(k)     ... mean loss incurred by lambdas(k)
% seLoss(k)     ... standard error of muLoss(k)
%%
y = y(:);
assert(size(y, 1) == size(X, 1));
%% process options
args = prepareArgs(varargin); % converts struct args to a cell array
[   nclasses      ...
    regType       ...
    lambda        ...
    preproc       ...
    fitFn         ...
    fitOptions    ...
    nlambdas      ...
    nfolds        ...
    useSErule     ...
    plotCv        ...
    ] = process_options(args    , ...
    'nclasses'      , nunique(y), ...
    'regType'       , 'none'    , ...
    'lambda'        ,  []       , ...
    'preproc'       ,  preprocessorCreate()       , ...
    'fitFn'         ,  ''       , ...
    'fitOptions'    , []        , ...
    'nlambdas'      , 10        , ...
    'nfolds'        , 5         , ...
    'useSErule'     , false     , ...
    'plotCv'        , false  );
%% set defaults
if isempty(nclasses)
    nclasses = min(nunique(y), 2);
end
isbinary = nclasses < 3;
if strcmpi(regType, 'none')
    regType = 'l2';
    if isempty(lambda)
        lambda = 0;
    end
end
if isempty(fitFn)
    switch lower(regType)
        case 'l1'
            fitFn = @L1GeneralProjection;
        case 'l2'
            fitFn = @logregFitL2Minfunc;
    end
end
opts = fitOptions;
if isempty(opts)
    opts.Display     = 'none';
    opts.verbose     = false;
    if size(X, 2) > 100
        opts.TolFun      = 1e-3;
        opts.MaxIter     = 200;
        opts.Method      = 'lbfgs';
        opts.MaxFunEvals = 2000;
        opts.TolX        = 1e-3;
        if strcmpi(funcName(fitFn), 'L1GeneralProjection')
            opts.order = -1; % Turn on using L-BFGS
            if size(X, 2) > 1000
                opts.corrections = 10; %  num. LBFGS corections
            end
        end
    end
end
if isempty(lambda)
    lambda = colvec(linspace(1e-5, 20, nlambdas));
end
%if ~isfield(preproc, 'includeOffset')
%    preproc.includeOffset = true;
%end
%% preprocess X
[preproc, X] = preprocessorApplyToTrain(preproc, X);
%% set objective
if isbinary
    [y, ySupport] = setSupport(y, [-1 1]);
    objective = @LogisticLossSimple;
else
    [y, ySupport] = setSupport(y, 1:nclasses);
    objective = @(w, X, y)SoftmaxLoss2(w, X, y, nclasses);
end
%% construct fit function / optimizer
fitFn = @(X, y, winit, l)fitFn(objective, winit, l, opts, X, y);
fitFn = @(X, y, lambda)fitWrapper(X, y, lambda, fitFn, nclasses, ...
    preproc.addOnes);
%%
if numel(lambda) == 1
    model = fitFn(X, y, lambda);
    muLoss = [];
    seLoss = [];
else
    %% cross validation
    if plotCv
        fprintf('cross validating over \n');
        disp(lambda)
    end
    lossFn = @(y, yhat)mean((y-yhat).^2);
    nfolds = min(size(X, 1), nfolds);
    
    [model, bestLambda, muLoss, seLoss] = ...
        fitCv(lambda, fitFn, @logregPredict, lossFn, X, y, nfolds, ...
              useSErule, plotCv);
end
%%
lambdas = lambda;
model.ySupport = ySupport;
model.preproc = preproc;
end % end of main function

function model = fitWrapper(X, y, lambda, fitFn, nclasses, includeOffset)
% wrap the fit function - this subfunction will be called repeatedly
% during cross validation.
%%
isbinary = nclasses < 3;
d = size(X, 2);
model.lambda = lambda;
lambda = lambda*ones(d, nclasses-1);
if includeOffset
    lambda(1, :) = 0; % don't penalize bias term
end
winit  = zeros(d, nclasses-1);
w = fitFn(X, y, winit(:), lambda(:));
if ~isbinary
    w = [reshape(w, [d nclasses-1]) zeros(d, 1)];
end
model.w = w;
model.binary = isbinary;
if isbinary
    model.ySupport = [-1 1];
else
    model.ySupport = 1:nclasses;
end
end
