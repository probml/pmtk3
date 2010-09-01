function [model] = linregFit(X, y, varargin)
% Fit a linear regression model by MLE or MAP estimation
% INPUTS
% X             ... N*D design matrix
% y             ... N*1 response vector
% OPTIONAL INPUTS:
% regType       ... L1, L2, none, scad (only used if likelihood is 'gaussian')
% likelihood    ... ['gaussian'], 'student', 'huber'
% lambda        ... regularizer
% fitOptions    ... optional  args (a cell array) to fitFn
% preproc       ... a struct, passed to preprocessorApplyToTtrain
%  Set preproc.addOnes = true if you want this model
%   to add a column of 1s to X for you (at train and test time)
%
% OUTPUTS:
% model         ... a struct, which you can pass directly to linregPredict
%%
[   regType         ...
    likelihood      ...
    lambda          ...
    fitOptions      ...
    preproc         ...
    ] = process_options(varargin , ...
    'regType'       , 'none' , ...
    'likelihood'    , 'gaussian', ...
    'lambda'        ,  []    , ...
    'fitOptions'    , []     , ...
    'preproc'       , preprocessorCreate('addOnes', true, 'standardizeX', false));


if isempty(fitOptions)
  fitOptions = defaultFitOptions(regType, size(X,2));
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
        if strcmpi(regType, 'none')
            if isempty(lambda)
                regType = 'l2'; lambda = 0; % not specifying regType or lambda means MLE
            else
                regType = 'l2'; % just specifying lambda turns on L2
            end
        end
        model.lambda = lambda;
        lambdaVec = lambda*ones(D,1);
        if preproc.addOnes
            lambdaVec(1, :) = 0; % don't penalize bias term
        end
        
        opts = fitOptions;
        winit = zeros(D,1);
        switch lower(regType)
            case 'l1'  , % lasso
                w = L1GeneralProjection(@(ww) SquaredError(ww,X,y), winit, lambdaVec(:), opts);
            case 'l2'  , % ridge using QR
                if lambda == 0
                    w = X\y;
                else
                    XX = [X; diag(sqrt(lambdaVec))];
                    yy = [y; zeros(D, 1)];
                    w  = XX \ yy;
                end
            case 'scad', % scad
                % this cannot handle vector-valued lambda, so it regularizes
                % the offset term... So set addOnes to false before calling
                w = linregSparseScadFitLLA( X, y, lambda, opts{:} );
        end
        
        model.w   = w;
        yhat = X*w;
        model.sigma2 = var((yhat - y).^2); % MLE of noise variance
        
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

