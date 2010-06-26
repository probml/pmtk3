function [model, X, lambdaVec] = logregFit(X, y, varargin)
% Fit a logistic regression model, (supports multiclass)
%% INPUTS: (specified as name value pairs)
% regType       ... 'L1' or 'L2' or 'none'
% nclasses      ... the number of output classes
% lambda        ... regularizer 
% fitOptions    ... optional fitMethod args (a struct)
% preproc       ... a struct, passed to preprocessorApplyToTtrain
%% OUTPUTS:
% model         ... a struct, which you can pass directly to logregPredict
% X             ... possibly transformed input

y = y(:);
assert(size(y, 1) == size(X, 1));
%% process options
args = prepareArgs(varargin); % converts struct args to a cell array
[   nclasses      ...
    regType       ...
    lambda        ...
    preproc       ...
    fitOptions    ...
    ] = process_options(args    , ...
    'nclasses'      , nunique(y), ...
    'regType'       , 'l2'    , ...
    'lambda'        ,  0       , ...
    'preproc'       ,  preprocessorCreate('addOnes', true, 'standardizeX', true)       , ...
    'fitOptions'    , []);


if isempty(fitOptions)
  fitOptions = defaultFitOptions(regType, size(X,2));
end

[preproc, X] = preprocessorApplyToTrain(preproc, X);
[N,D] = size(X); %#ok


isbinary = nclasses < 3;
if isbinary
    [y, model.ySupport] = setSupport(y, [-1 1]);
    loss = @(w) LogisticLossSimple(w, X, y);
     model.binary = true;
else
    [y, model.ySupport] = setSupport(y, 1:nclasses);
    loss = @(w) SoftmaxLoss2(w, X, y, nclasses);
    model.binary = false;
end
model.lambda = lambda;

lambdaVec = lambda*ones(D, nclasses-1);
  
if preproc.addOnes
    lambdaVec(1, :) = 0; % don't penalize bias term
end
winit  = zeros(D, nclasses-1);

switch lower(regType)
  case 'l1'
    w = L1GeneralProjection(loss, winit(:), lambdaVec(:), fitOptions);
  case 'l2'
    penloss = @(w)penalizedL2(w, loss, lambdaVec(:));
    w = minFunc(penloss, winit(:), fitOptions);
end

if ~isbinary
    w = [reshape(w, [D nclasses-1]) zeros(D, 1)];
end
model.w = w;
model.preproc = preproc;
model.type = 'logreg';
end 

function opts = defaultFitOptions(regType, D) 
% Set options for minFunc
opts.Display     = 'none';
opts.verbose     = false;
opts.TolFun      = 1e-3;
opts.MaxIter     = 200;
opts.Method      = 'lbfgs'; % for minFunc
opts.MaxFunEvals = 2000;
opts.TolX        = 1e-3;
if strcmpi(regType, 'l1')
  % set options for L1general
  opts.order = -1; % Turn on L-BFGS
  if D > 1000
    opts.corrections = 10; %  num. LBFGS corections
  end
end
end

