function [params, data] = initMixedDataFA(data, params, options)
% [PARAMS] = initMixedDataFA(DATA, [], OPTIONS) initializes the factor analysis model
%   parameters for mixed data type (handles missing data).
%
% DATA is a struct with the following fields,
%   continuous : observation (Dc x N)
%   binary     : observation (Db x N)
%   categorical : observation (Dm x N)
%
% OPTIONS is a struct with the following fields,
%   Dz         : number of latent factors 
%   nClass     : number of Classes (Dm x 1)
%   initMethod : PCA is used if 'initMethod' is set to 'PCA' (default is 'random')
%
% PARAMS is a struct with the following fields
%   mean         : prior mean on latent factors (Dz x 1) 
%   covMat       : prior covariance on latent factors (Dz x Dz)
%   S0           : IW prior (scale) for covariance (Dz x Dz)
%   nu0          : IW prior (dof) for covariance (scalar) 
%   beta         : loading factor matrix (Dc+Db+Dm x Dz) 
%   betaCont     : loading factor matrix for continuous (Dc x Dz) 
%   betaBin      : loading factor matrix for binary (Db x Dz) 
%   xi           : variational parameters for Jaakola's bound (Db x N)
%   betaMult     : loading factor matrix for categorical (Dm x Dz) 
%   A            : curvature for Bohning bound (struct of length Db)
%   invA         : inv(A)
%   psi          : variational parameters for Bohning bound(sum(nClass) x N)
%   lambda       : regularization params for beta (scalar) 
%   noiseCovMat  : Noise covariance matrix for observations (Dc x Dc)
%   noisePrecMat : Inverse of noiseCovMat (Dc x Dc)
%   a and b      : regularization params for noise covriance (scalar) 
% Default settings set the prior parameters so that there is 'zero' prior.
%
% [PARAMS, DATA] = initFA(DATA, [], OPTIONS) precomputes Y.^2 as a field (YY)
%   to the DATA. It also adds empty 'continuous', 'binary', 'categorical'
%   fields if those are not present in the original DATA variable.
%
% See testLearnMixedDataFA.m for an example.
% See also : inferMixedDataFA, inferMixedDataFA_miss, inferMixedDataFA_jaakkola, maxParamsMixedDataFA 
% 
% Written by Emtiyaz, CS, UBC,
% modified on June 09, 2010

  if ~isfield(data, 'continuous'); data.continuous = []; end;
  if ~isfield(data, 'binary'); data.binary = []; end;
  if ~isfield(data, 'categorical'); data.categorical = []; end;

  [Dc,Nc] = size(data.continuous);
  [Db,Nb] = size(data.binary);
  [Dm,Nm] = size(data.categorical)
  N = max([Nb Nc Nm]);
  params.Dc = Dc;
  params.Db = Db;
  params.Dm = Dm;

  [Dz, s0, scale, nClass, initMethod] = myProcessOptions(options, 'Dz',2, 's0', 0, 'scale', 3, 'nClass', [], 'initMethod', 'random');

  % inverse wishart prior for covMat
  params.priorCovMat = 'invWishart';
  params.S0 = s0*eye(Dz);
  params.nu0 = -(Dz + 1);
  % covMat
  params.covMat = eye(Dz,Dz);
  params.precMat = inv(params.covMat);
  % mean
  params.mean = scale*randn(Dz,1);
  % regularization for loading factors
  params.lambda = 0;
  % regularization for noise covariance 
  params.a = -1;
  params.b = 0;

  % intialize loading factors
  % continuous
  params.beta = [];
  if Dc > 0
    switch initMethod 
      case 'random'
        params.noiseCovMat = eye(Dc,Dc);
        params.noisePrecMat = inv(params.noiseCovMat);
        params.betaCont = rand(Dc,Dz);%rand(Dc,Dz);
        params.beta = [params.beta; params.betaCont];
      case 'PCA'
        mean_ = mean(data.continuous,2);
        Y = bsxfun(@minus, data.continuous,  mean_);
        covMat = Y*Y';
        [U,S,V] = svd(covMat);
        params.noiseCovMat = sum(sum((covMat - U(:,1:Dz)*S(1:Dz,1:Dz)*V(:,1:Dz)').^2))*eye(Dc,Dc);
        params.noisePrecMat = inv(params.noiseCovMat);
        params.betaCont = U(:,1:Dz)*sqrt(S(1:Dz,1:Dz));
        params.beta = [params.beta; params.betaCont];
      otherwise
        error('no such method')
    end
  end
  % binary
  if Db > 0
    params.betaBin = rand(Db,Dz);% rand
    params.beta = [params.beta; params.betaBin];
    params.xi = rand(Db,N);
  end
  % categorical
  if Dm > 0
    if ~isfield(params, 'nClass')
      if ~isempty(nClass) 
        params.nClass = nClass;
      else
        error('nClass not defined, pass it through options');
      end
    end
    % curvature for Bohning bound
    for d = 1:length(params.nClass)
      M = params.nClass(d)-1;
      A{d} = (eye(M) - ones(M,M)/(M+1))/2;
      invA{d} = inv(A{d});
    end
    params.A = A;
    params.invA = invA;
    params.betaMult = rand(sum(params.nClass-1),Dz);%rand(sum(params.nClass-1),Dz);
    params.beta = [params.beta; params.betaMult];
    % variational parameters
    params.psi = params.betaMult*repmat(params.mean, 1,N);
  end

  % precompute y.^2 and add it to the data
  if Dc >0
    if ~isfield(data, 'YY')
      y = data.continuous;
      y(isnan(y)) = 0;
      data.YY = sum(y.*y,2);
    end
  end

