function [model] = linregFit(X, y, varargin)
% Fit a linear regression model
% INPUTS
% X             ... N*D design matrix
% y             ... N*1 response vector
% OPTIONAL INPUTS:
% regType       ... L1, L2, none, scad
% lambda        ... regularizer 
% fitOptions    ... optional  args (a cell array) to fitFn
%                   @(X, y, lambda, fitOptions{:})
% preproc       ... a struct, passed to preprocessorApplyToTtrain
% 
% OUTPUTS:
% model         ... a struct, which you can pass directly to linregPredict


args = prepareArgs(varargin); % converts struct args to a cell array
[   regType         ...
    lambda          ...
    fitOptions      ...
    preproc         ...
    ] = process_options(args , ...
    'regType'       , 'none' , ...
    'lambda'        ,  []    , ...
    'fitOptions'    , {}     , ...
    'preproc'       , preprocessorCreate('addOnes', true, 'standardizeX', false));

Xraw = X;
[preproc, X] = preprocessorApplyToTrain(preproc, X);
[N,D] = size(X); %#ok
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
  case 'l2'  , % ridge
    w = linregFitL2QR(X, y, lambdaVec(:), opts{:});
  case 'scad', % scad
    % this cannot handle vector-valued lambda, so it regularizes
    % the offset term... So set addOnes to false before calling
    w = linregSparseScadFitLLA( X, y, lambda, opts{:} );
end

model.w   = w;
model.preproc  = preproc;
yhat = linregPredict(model, Xraw);
model.sigma2 = var((yhat - y).^2); % MLE of noise variance

end % end of main function

function w = linregFitL2QR(X, y, lambda)
% Ridge regression using QR
% lambda can be a vector

if lambda == 0
  w = X\y;
else
  D = size(X,2);
  if isscalar(lambda)
    lambda = lambda*ones(D,1);
  end
  XX  = [X; diag(sqrt(lambda))];
  yy = [y; zeros(D,1)];
  w  = XX \ yy; 
end

end

