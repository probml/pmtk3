function [params, data] = initFA(data, params, options)
% [PARAMS] = initFA(DATA, [], OPTIONS) initializes the factor analysis model
%   parameters (handles missing data).
%
% DATA is a struct with the following fields,
%   continuous : observation (DcxN)
%
% OPTIONS is a struct with the following fields,
%   Dz         : number of latent factors 
%   initMethod : PCA is used if 'initMethod' is set to 'PCA' (default is 'random')
%
% PARAMS is a struct with the following fields
%   mean         : prior mean on latent factors (Dz x 1) 
%   covMat       : prior covariance on latent factors (Dz x Dz)
%   S0           : IW prior (scale) for covariance (Dz x Dz)
%   nu0          : IW prior (dof) for covariance (scalar) 
%   beta         : loading factor matrix (D x Dz) 
%   lambda       : regularization params for beta (scalar) 
%   noiseCovMat  : Noise covariance matrix for observations (Dc x Dc)
%   noisePrecMat : Inverse of noiseCovMat (Dc x Dc)
%   a and b      : regularization params for noise covriance (scalar) 
% Default settings set the prior parameters so that there is 'zero' prior.
%
% [PARAMS, DATA] = initFA(DATA, [], OPTIONS) precomputes Y.^2 as a field (YY)
%   to the data.
%
% See testLearnFA.m for an example.
% See also : inferFA, maxParamsFA, inferMixedDataFA
% 
% Written by Emtiyaz, CS, UBC,
% modified on June 07, 2010

  [Dc,Nc] = size(data.continuous);

  [Dz, s0, scale, initMethod] = myProcessOptions(options, 'Dz',2, 's0', 0, 'scale', 3, 'initMethod', 'random');

  % inverse wishart prior for covMat
  params.S0 = s0*eye(Dz);
  params.nu0 = -(Dz + 1);
  % covMat
  params.covMat = eye(Dz,Dz);
  params.precMat = inv(params.covMat);
  % mean
  params.mean = zeros(Dz,1);
  % regularization for loading factors
  params.lambda = 0;
  % regularization for noise covariance 
  params.a = -1;
  params.b = 0;

  % intialize beta and noiseCovMat
  switch initMethod 
    case 'random'
      % random initialization
      params.noiseCovMat = eye(Dc,Dc);
      params.noisePrecMat = inv(params.noiseCovMat);
      params.beta = rand(Dc,Dz);
      params.bias = zeros(Dc,1);
    case 'PCA'
      % fill in the missing values if with mean and remove mean
      Y = data.continuous;
      miss = isnan(Y);
      Y(miss) = 0;
      mean_ = sum(Y,2)./sum(~miss,2);
      Y = bsxfun(@minus, Y,  mean_);
      Y(miss) = 0;
      std_ = sum(Y.^2,2)./sum(~miss,2);
      Y = bsxfun(@rdivide, Y, std_);
      % compute SVD
      covMat = Y*Y';
      [U,S,V] = svd(covMat);
      params.noiseCovMat = sum(sum((covMat - U(:,1:Dz)*S(1:Dz,1:Dz)*V(:,1:Dz)').^2))*eye(Dc,Dc)/(Dc^2);
      params.noisePrecMat = inv(params.noiseCovMat);
      params.beta = U(:,1:Dz)*sqrt(S(1:Dz,1:Dz));
      params.mean = pinv(params.beta)*mean_;
      params.bias = zeros(Dc,1);
    otherwise
      error('no such method')
  end

  % precompute y.^2 and add it to the data
  if ~isfield(data, 'YY')
    y = data.continuous;
    y(isnan(y)) = 0;
    data.YY = sum(y.*y,2);
  end

