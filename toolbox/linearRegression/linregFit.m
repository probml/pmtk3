function [model, varargout] = linregFit(X, y, varargin)
% Fit a linear regression model
%% INPUTS: 
% regType       ... L1 or L2
% lambda        ... regularizer (can be a range tuned via cv)
% kernelFn      ... @(X, X1, kernelParam)
% kernelParam   ... e.g. sigma in an RBF kernel (can be a range tuned via cv)
% fitMethod     ... regType dependent, e.g. 'qr', 'lars'
% fitOptions    ... optional fitMethod args (a cell array)
% standardizeX  ... if true, call mkUnitVariance(center(X))
% rescaleX      ... if true, call rescaleData(X, scaleXrange(1), scaleXrange(2))         
% scaleXrange   ... [minX, maxX], e.g. [-1 1] 
% nregParams    ... number of auto-generated regularizer params to cv over
% nkernelParams ... number of auto-generated kernel params to cv over
% nfolds        ... number of folds in the cross validation
% useSErule     ... if true, pick simplest model within one stderr of best
% doPlot        ... if true, plot the cv curve or cv grid
%% OUTPUTS:
% model         ... a struct, which you can pass directly to linregPredict
% varargout{1}  ... the best parameter values chosen by CV
% varargout{2}  ... mean loss
% varargout{3}  ... standard error of varargout{2}
%% process options
args = prepareArgs(varargin); % converts struct args to a cell array
[   regType       ...         
    lambda        ...         
    kernelFn      ...         
    kernelParam   ...         
    fitMethod     ...         
    fitOptions    ...         
    standardizeX  ...         
    rescaleX      ...         
    scaleXrange   ...         
    nlambdas      ...       
    nkernelParams ...        
    nfolds        ...
    useSErule     ...
    doPlot        ...
    ] = process_options(args , ...
    'regType'       , 'l2'   , ...
    'lambda'        ,  []    , ...
    'kernelFn'      ,  []    , ...
    'kernelParam'   ,  []    , ...
    'fitMethod'     ,  ''    , ...
    'fitOptions'    , {}     , ...
    'standardizeX'  , true   , ...
    'rescaleX'      , false  , ...
    'scaleXrange'   , [-1,1] , ...
    'nlambdas'      , 20     , ...
    'nkernelParams' , 10     , ...
    'nfolds'        , 5      , ...        
    'useSErule'     , false  , ...
    'doPlot'        , false  );
%% set defaults        
if isempty(fitMethod)
    switch lower(regType)
        case 'l1'  , fitMethod = 'lars';
        case 'l2'  , fitMethod = 'qr';
    end
end
%% preprocess X, (kernelization happens later)
pre = struct(); 
if standardizeX
    [X, pre.Xmu]   = center(X);
    [X, pre.Xstnd] = mkUnitVariance(X);
end
if rescaleX
    X = rescale(X, scaleXrange(1), scaleXrange(2));
    pre.Xscale = scaleXrange;
end
%% construct fit function
opts = fitOptions; 
switch lower(fitMethod)
    % L2
    case 'qr'            
        fitCore = @(X,y,l) linregFitL2QR(X,y,l,opts{:});
    case 'minfunc'       
        fitCore = @(X,y,l) linregFitL2Minfunc(X,y,l,opts{:});
    % L1
    case 'shooting'      
        fitCore = @(X,y,l) linregFitL1Shooting(X,y,l,opts{:});
    case 'lars'          
        fitCore = @(X,y,l) linregFitL1LarsSingleLambda(X,y,l,opts{:});
    case 'interiorpoint' 
        fitCore = @(X,y,l) linregFitL1InteriorPoint(X,y,l,opts{:});
    case 'em'            
         sigma = 1;
         fitCore = @(X,y,l)linregFitSparseEm...
             (X, y,'laplace',l/(2*sigma),1,sigma,opts{:});
    otherwise
         error('unrecognized fitMethod: %s', fitMethod);
end
if isempty(kernelFn)
    fitfn = @(X, y, param)simpleFit(X, y, param, fitCore); 
else
    fitfn = @(X, y, param)kernelizedFit(X, y, param(1), param(2), fitCore, kernelFn);
end

%% constuct parameter space
if ~isempty(kernelFn) && isempty(kernelParam)
    switch func2str(kernelFn)
        case 'rbfKernel'
            kernelParam = logspace(-1, 1, nkernelParams);
        case 'kernelPoly', 
            kernelParam = 1:nkernelParams;
        otherwise
            kernelParam = logspace(-1, 1, nkernelParams);
    end
end
if isempty(lambda)
    switch lower(regType)
        case 'l1'
            if isempty(kernelFn)
                K = X;
            else
                K = kernelFn(X, X, mean(kernelParam)); 
            end
            lambdaMax = lambdaMaxLasso(K, center(y)); 
            lambda = linspace(1e-5, lambdaMax, nlambdas); 
        case 'l2'
            lambda = linspace(1e-5, 20, nlambdas); 
    end
end

if isempty(kernelParam)
   paramRange = lambda; 
else
   paramRange = crossProduct(lambda, kernelParam); 
end
%% cross validation
lossFn = @(y, yhat)mean((y-yhat).^2);  
nfolds = min(size(X, 1), nfolds); 
[model, varargout{1}, varargout{2}, varargout{3}] = ...
fitCv(paramRange, fitfn, @linregPredict, lossFn, X, y, nfolds, useSErule, doPlot);

model = catstruct(model, pre);  % add preprocessor info to model
%%
yhat = linregPredict(model, X);
model.sigma2 = var((yhat - y).^2); % MLE

end % end of main function


function model = simpleFit(X, y, lambda, fitFn)
% Fit function wrapper 
    [y, ybar] = center(y);  
    w   = fitFn(X, y, lambda);
    model.w0  = ybar - mean(X)*w; 
    model.w   = w; 
end

function model = kernelizedFit(X, y, lambda, kernelParam, fitfn, kernelFn)
% Fit function wrapper
    [y, ybar] = center(y);  
    K = kernelFn(X, X, kernelParam); 
    w  = fitfn(K, y, lambda);
    model.w0 = ybar - mean(K)*w;
    model.w  = w; 
    model.basis = X;
    model.kernelFn = kernelFn;
    model.kernelParam = kernelParam;
end