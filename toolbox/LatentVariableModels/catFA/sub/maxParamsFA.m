function params = maxParamsFA(ss, data, params, options)
% PARAMS = maxParamsFA(SS, DATA, PARAMS, []) finds parameters which maximize
%   the (lower bound to) log-likelihood. This function is used inside EM (using
%   'learnEm') and is compatible with the following inference functions :
%   inferFA, inferFA_miss. This function also handles missing data.
% 
% PARAMS is a struct (see initFA for details of params) 
% SS is the output of inference code and has the follwing fields (Z are latent factors, y is data, Dc is data dim),
%    sumMean   : sum E(Z) over data points (Dz x 1)
%    sumCovMat : sum E(Z*Z') over data points (Dz x Dz)
%    sumLhs    : sum y*E(Z) over data points (Dc x Dz)
%    sumPhi    : sum of residuals over data points (Dc x 1)
%    beta      : Present only if there are missing variables, and contains
%        estimate of loading factor matrix(see inferFA_miss for details). 
% 
% [SS, LOGLIK, POSTDIST] = maxParamsFA(DATA, PARAMS, OPTIONS) specifies options.
% The following OPTIONS can be specified,
%    estimateBeta  : 1 if loading factor matrix needs to be estimated.
%    estimateCovMat : 1 if covMat matrix needs to be estimated.
%
% See testLearnFA.m for an example.
% See also : initFA, inferFA, inferFA_miss 
% 
% Written by Emtiyaz, CS, UBC,
% modified on June 07, 2010

  [D,N] = size(data.continuous);
  Dz = size(params.mean,1);

  [estimateMean, estimateBeta, estimateCovMat, estimateNoiseCovMat] = myProcessOptions(options, 'estimateMean', 0, 'estimateBeta', 1, 'estimateCovMat', 0, 'estimateNoiseCovMat', 1);
  % missing data?
  idxMiss = isnan(data.continuous);
  missing = sum(sum(idxMiss));
  idxObs = ~idxMiss;
  Nobs = sum(idxObs,2);

  % mean and CovMat
  den = params.nu0 + Dz + 1 + N;
  if estimateMean
    params.mean = ss.sumMean/N;
    if estimateCovMat
      params.covMat = (params.S0 + ss.sumCovMat)/den - N*params.mean*params.mean'/den;
      params.precMat = inv(params.covMat);
    end
  else 
    if estimateCovMat
      params.covMat = (params.S0 + ss.sumCovMat1)/den;
      params.precMat = inv(params.covMat);
    end
  end


  %{
  % mean
  if estimateMean
    params.mean = ss.sumMean/N;
  end
  % covMat
  if estimateCovMat
    den = params.nu0 + Dz + 1 + N;
    params.covMat = (params.S0 + ss.sumCovMat)/den - N*params.mean*params.mean'/den;
    params.precMat = inv(params.covMat);
  end
  %}

  if estimateBeta
    % loading factors
    if missing 
      params.beta = ss.beta;
      if estimateNoiseCovMat;
        params.noiseCovMat = diag((2*params.b + data.YY - diag(params.beta*ss.sumLhs'))./(Nobs(:) + 2*(params.a + 1)));
      end
    else
      params.beta = ss.sumLhs*inv(ss.sumCovMat + params.lambda*eye(Dz));
      if estimateNoiseCovMat;
        params.noiseCovMat = diag(2*params.b + params.lambda*diag(params.beta*params.beta') + data.YY - diag(params.beta*ss.sumLhs'))/(N+2*(params.a + 1));
      end
    end
  else
    % noise covariance
    if estimateNoiseCovMat;
      numl = ss.sumPhi + 2*params.b + params.lambda*diag(params.beta*params.beta');
      params.noiseCovMat = diag(numl./(Nobs + 2*(params.a + 1)));
    end
  end
  params.noisePrecMat = diag(1./diag(params.noiseCovMat));

