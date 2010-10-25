function [model, path] = logregFitPathCv(X, y, varargin)
% Fit a regularization path for logistic regression model 
% using L1 or L2 regularizer  and then pick best model.
% Also return params on the path.
% (This is a wrapper to the glmnet package.)
% INPUTS
% X             ... N*D design matrix
% y             ... N*1 response vector
% OPTIONAL INPUTS:
% regType       ... L1, L2
% options       ... see glmnetSet
%
% preproc       ... a struct, passed to preprocessorApplyToTtrain
%   glmnet computes offset term automatically.
%   The (training) data is standardized by default.
%
% OUTPUTS:
% model         ... a linear regression object
% path.w        ... w(:,j) is coeff for j'th point on path
% path.w        ... w0(j) is offset
% path.lambdas  ... contains lambdas values searched over

% This file is from pmtk3.googlecode.com


% default preprocessing
pp = preprocessorCreate();

[   regType         ...
  preproc         ...
 options           ...
 nfolds           ...
 verbose          ...
  ] = process_options(varargin , ...
  'regType'       , 'enet' , ...
  'preproc'       , pp, ...
  'options'       , glmnetSet(), ...
  'nfolds'        , 5, ...
  'verbose'       , false);


[preproc, X] = preprocessorApplyToTrain(preproc, X);
[N,D] = size(X);

% glmnet minimizes
% (1/N) NLL(w) + lambda*[0.5(1-alpha) ||w||_2 + alpha ||w||_1 ]
% so alpha = 1 corresponds to lasso,
% alpha = 0 corresponds to ridge
% alpha = 0.9 is a form of elastic net

switch lower(regType)
  case 'l1'  , % lasso
    options.alpha = 1;
  case 'l2', % ridge
    options.alpha = 0;
  case 'enet', % elastic net
    options.alpha = 0.9;
  otherwise
    error(['unknown regtype ' regType])
end

K = nunique(y);
[y, ySupport] = setSupport(y, 1:K);

nfolds = 5; foldid = []; type = [];
if K==2
  family = 'binomial';
else
  family = 'multinomial';
end

verbose = 0;
CVerr=cvglmnetMulticlass(X,y,nfolds,foldid, type, family, options, verbose);

ndx  = find(CVerr.lambda_1se == CVerr.glmnetOptions.lambda);

% create model corresponding to best param value
models = CVerr.glmnet_object;
if K==2 && strcmpi(family, 'binomial')
  w = models.beta(:, ndx);
else
  w = zeros(D, K);
  for k=1:K
    w(:,k) = models.beta{k}(:,ndx);
  end
end
w0 = models.a0(:,ndx);
ww = [rowvec(w0); w];


preproc.addOnes = true; % for offset
preproc.standardize = false;% params on original scale (undoing standardization)
model = logregCreate(ww, preproc, ySupport);
model.lambda = models.lambda(ndx);

path.w = models.beta;
path.w0 = models.a0;
path.lambdas = models.lambda;

end % end of main function
