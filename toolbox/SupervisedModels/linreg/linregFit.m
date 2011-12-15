function [model] = linregFit(X, y, varargin)
% Fit a linear regression model by MLE or MAP estimation
% INPUTS
% X             ... N*D design matrix
% y             ... N*1 response vector
% OPTIONAL INPUTS:
% weights       ... N*1 weight vector for eg weighted least squares
% regType       ... L1, L2, none, scad (only used if likelihood is 'gaussian')
% likelihood    ... ['gaussian'], 'student', 'huber', 'scad'
% lambda        ... regularizer
% preproc       ... a struct, passed to preprocessorApplyToTtrain
%    Set preproc.addOnes = true if you want this model
%    to add a column of 1s to X for you (at train and test time)
% fitOptions    ... optional  args (a cell array) to fitFn
% fitFnName         ... Name of fitting method to use.
%   Options:
%    regType = L1:  [L1GeneralProjection] or L1LS
%    regType = L2:  [QR] or minfunc
% winit         ...  Initial value of w; can be used for warm starting
%
% OUTPUTS:
% model         ... a struct, which you can pass directly to linregPredict

% This file is from pmtk3.googlecode.com

% 24 Oct 2010 by KPM
% added weights for weighted linear regression
% See linregWeightedDemo

% default preprocessing
pp = preprocessorCreate('addOnes', true, 'standardizeX', false);
[N,D] = size(X);
[   weights         ...
  regType         ...
  likelihood      ...
  lambda          ...
  fitOptions      ...
  preproc         ...
  fitFnName       ...
  winit           ...
  ] = process_options(varargin , ...
  'weights'        , ones(size(X,1),1), ...
  'regType'       , 'none' , ...
  'likelihood'    , 'gaussian', ...
  'lambda'        ,  []    , ...
  'fitOptions'    , []     , ...
  'preproc'       , pp, ...
  'fitFnName'     , [], ...
  'winit'         , []);

if isempty(preproc), preproc = preprocessorCreate(); end
% we don't call preprocApply here since some
% methods (eg huber) treat the offset differently

if isfield(preproc, 'addones') && preproc.addOnes,  D = D+1; end
if isempty(winit), winit = zeros(D,1); end

if strcmpi(regType, 'none')
  if isempty(lambda)
    regType = 'l2'; lambda = 0; % not specifying regType or lambda means MLE
  else
    regType = 'l2'; % just specifying lambda turns on L2
  end
end
    
if isempty(fitOptions)
  fitOptions = defaultFitOptions(regType, size(X,2));
end

if isempty(fitFnName)
  switch lower(regType)
    case 'l1', fitFnName = 'l1GeneralProjection'; % or l1ls
    case 'l2', fitFnName = 'qr'; %
  end
end

switch lower(likelihood)
  
  case 'huber'
    
    includeOffset = preproc.addOnes;
    delta         = 1;
    m             = linregRobustHuberFit(X, y, delta, includeOffset);
    if includeOffset
      model.w = [m.w0; m.w(:)];
    else
      model.w = m.w;
    end
    model.sigma2  = m.sigma2;
    
  case 'student'
    
    m = linregRobustStudentFit(X, y);
    model.w      = [m.w0; m.w(:)];
    model.sigma2 = m.sigma2;
    model.dof    = m.dof;
    preproc.addOnes = true;
    
  case 'gaussian'
    [preproc, X] = preprocessorApplyToTrain(preproc, X);
    [N,D] = size(X);
    model.lambda = lambda;
    lambdaVec = lambda*ones(D,1);
    if preproc.addOnes
      lambdaVec(1, :) = 0; % don't penalize bias term
    end
    winit = zeros(D,1);
    opts = fitOptions;
    switch lower(regType)
      
      case 'l1'  , % lasso
          if lambda==0
              R = diag(sqrt(weights));
              %w = X\y;
              w = (R*X) \ (R*y);
          else
              switch lower(fitFnName)
                  case 'l1generalprojection'
                      w = L1GeneralProjection(@(ww) squaredErrorObjective(ww,X,y,weights), ...
                          winit, lambdaVec(:), opts);
                  case 'l1ls'
                      % this cannot handle vector-valued lambda, so it regularizes
                      % the off5et term... So set addOnes to false before calling
                      tol = 1e-3; quiet = true;
                      w = l1_ls(X, y, lambda, tol, quiet);
                  otherwise
                      error(['unrecognized fitFnName ' fitFnName])
              end
          end
        
      case 'l2'  , % ridge
        switch lower(fitFnName)
          case 'qr',
            
            if lambda == 0
              R = diag(sqrt(weights));
              %w = X\y;
              w = (R*X) \ (R*y);
            else
              weights2 = [weights; ones(D,1)];
              R = diag(sqrt(weights2));
              XX = [X; diag(sqrt(lambdaVec))];
              yy = [y; zeros(D, 1)];
              %w  = XX \ yy;
              w = (R*XX) \ (R*yy);
            end
          case 'minfunc'
            loss = @(ww) SquaredErrorObjective(ww, X, y, weights);
              penloss = @(ww)penalizedL2(ww, loss, lambdaVec(:));
              [w, opt.finalObj, opt.exitflag, opt.output] = ...
                minFunc(penloss, winit(:), opts);
        end
        
      case 'scad', % scad
        % this cannot handle vector-valued lambda, so it regularizes
        % the offset term... So set addOnes to false before calling
        w = linregSparseScadFitLLA( X, y, lambda, opts{:} );
    end
    
    model.w   = w;
    yhat = X*w;
    %model.sigma2 = var((yhat - y).^2); % MLE of noise variance
    if sum(weights)==0
      model.sigma2 = eps;
    else
      model.sigma2 = sum(weights .* (y-yhat).^2) / sum(weights);
    end
  otherwise
    error('%s is not a valid likelihood type', likelihood);
end


model.preproc  = preproc;
model.modelType = 'linreg';
model.likelihood = likelihood;

end % end of main function

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

