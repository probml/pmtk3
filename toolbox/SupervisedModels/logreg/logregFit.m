function [model, X, lambdaVec, opt] = logregFit(X, y, varargin)
% Fit a logistic regression model, (supports multiclass)
% INPUTS:
% X: N*D
% y: N*1 where y(i) in {1,..,C} or {0,1} or {-1,+1}
%   or  N*C where y(i,:) is a one-of-C encoding
%   Dummy encoding only supported for multi-class case
%
% OPTIONAL INPUTS: (specified as name value pairs)
% weights       ... N*1, default 1s
% nclasses      ... Needed if y does not contain all class labels
% regType       ... 'L1' or 'L2' or 'none'
% lambda        ... regularizer 
% fitOptions    ... optional fitMethod args (a struct)
% preproc       ... a struct, passed to preprocessorApplyToTtrain
%                      By default, this adds ones and standardizes 
% winit         ... initial value, used for warm starting
%                    of size D*C (first row is offset vector)
%                    or size D*1 for binary
% OUTPUTS:
% model         ... a struct, which you can pass directly to logregPredict
%    model.w is a D*C matrix, where model.w(1,:) contains the offset vector
%    if preproc.addOnes = true
%   model.w is D*1 for binary 
% X             ... possibly transformed input
% lambdaVec     ... vector of regularizers, including 0 for offset
% opt           ... output of optimizer 
%%

% This file is from pmtk3.googlecode.com


% Important change on 7 Sep 2010 by KPM
% Now the weight matrix in the multiclass case is D*C
% instead of D*(C-1), so we switch from SoftmaxLoss2 to SoftmaxLoss.
% This means winit should be D*C as well.
% This simplifies warm-starting, since the output (stored value)
% has always been D*C.
% (LambdaVec has been made D*C as well)

% 4 Oct 2010 by KPM
% In the multiclass case, we use ydummy as a 1-of-C encoding.
% This allows us to use logregFit inside EM with soft targets.
% The SoftmaxLossDummy function is now faster.

% 24 Oct 2010 by KPM
% added weights for weighted logistic regression
% See logregWeightedDemo

pp = preprocessorCreate('addOnes', true, 'standardizeX', true);

args = prepareArgs(varargin); % converts struct args to a cell array
[   weights       ....
  nclasses      ...
    regType       ...
    lambda        ...
    preproc       ...
    fitOptions    ...
    winit         ...
    ] = process_options(args    , ...
    'weights'       , ones(size(X,1),1), ...
    'nclasses'      , [], ...
    'regType'       , 'l2'    , ...
    'lambda'        ,  0       , ...
    'preproc'       ,  pp       , ...
    'fitOptions'    , []      , ...
    'winit'         , []);

  if isempty(preproc), preproc = preprocessorCreate(); end

  
  %y = y(:);
%assert(size(y, 1) == size(X,1));


if isvector(y)
  y = y(:);
  if isempty(nclasses), nclasses = nunique(y); end
  if nclasses==2
    model.binary = true;
  else
    model.binary = false;
    [y, model.ySupport] = setSupport(y, 1:nclasses);
    ydummy = dummyEncoding(y, nclasses);
  end
else
  model.binary = false;
  ydummy = y;
  nclasses = size(ydummy, 2);
  model.ySupport = 1:nclasses;
  clear y
end


if isempty(fitOptions)
  fitOptions = defaultFitOptions(regType, size(X,2));
end


[preproc, X] = preprocessorApplyToTrain(preproc, X);
D = size(X,2); % will be num features plus 1 if we added col of 1s

if model.binary
    [y, model.ySupport] = setSupport(y, [-1 1]);
    loss = @(w) LogisticLossSimple(w, X, y, weights);
else
    %[y, model.ySupport] = setSupport(y, 1:nclasses);
    %loss = @(w) SoftmaxLoss2(w, X, y, nclasses);
    %loss = @(w) SoftmaxLoss(w, X, y, nclasses);
    loss = @(w) SoftmaxLossDummy(w, X, ydummy, weights);
end
model.lambda = lambda;

if model.binary
  lambdaVec = lambda*ones(D, 1);
else
  lambdaVec = lambda*ones(D, nclasses);
end
if preproc.addOnes
    lambdaVec(1, :) = 0; % don't penalize bias term
end

if isempty(winit)
  %winit  = zeros(D, nclasses-1);
  if model.binary
    winit  = zeros(D, 1);
  else
    winit  = zeros(D, nclasses);
  end
  
end

switch lower(regType)
  case 'l1'
    [w, opt] = L1GeneralProjection(loss, winit(:), lambdaVec(:), fitOptions);
  case 'l2'
    penloss = @(w)penalizedL2(w, loss, lambdaVec(:));
    %w = minFunc(penloss, winit(:), fitOptions);
    [w, opt.finalObj, opt.exitflag, opt.output] = ...
      minFunc(penloss, winit(:), fitOptions);
end

if ~model.binary
    %w = [reshape(w, [D nclasses-1]) zeros(D, 1)];
    w = reshape(w, [D nclasses]);
end
model.nclasses  = nclasses;
model.w = w;
model.preproc = preproc;
model.modelType = 'logreg';
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

