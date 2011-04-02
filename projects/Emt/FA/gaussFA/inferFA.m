function [ss, logLik, postDist] = inferFA(data, params, options)
% [SS, LOGLIK, POSTDIST] = inferFA(DATA, PARAMS, []) runs inference for factor
% analysis model with continuous data. See 'help initFA' for details on data
% format for DATA and PARAMS. This does not handles missing data. See
% inferFA_miss for code that handles missing data.
% 
% POSTDIST has the follwing fields (Dz = #latentFactors, N = #observations),
%    mean    : posterior mean (Dz x N)
%    covMat  : posterior covariance matrix (Dz x Dz x N)
%    precMat : inv(covMat)
%    
% SS has the follwing fields (Z are latent factors, y is data, Dc is data dim),
%    sumMean   : sum E(Z) over data points (Dz x 1)
%    sumCovMat : sum E(Z*Z') over data points (Dz x Dz)
%    sumLhs    : sum y*E(Z) over data points (Dc x Dz)
%    sumPhi    : sum of residuals over data points (Dc x 1)
% 
% [SS, LOGLIK, POSTDIST] = inferFA(DATA, PARAMS, OPTIONS) specifies options.
% The following OPTIONS can be specified,
%    computeLogLik : 1 if logLik needs to be computed.
%    computeSs     : 1 if SuffStats needs to be computed. 
%    estimateBeta  : 1 if loading factor matrix needs to be estimated.
%
% See testLearnFA.m for an example.
% See also : maxParamsFA, initFA, inferMixedDataFA
% 
% Written by Emtiyaz, CS, UBC,
% modified on June 07, 2010

  [computeSs, computeLogLik, estimateBeta] = myProcessOptions(options, 'computeSs', 1, 'computeLogLik', 1, 'estimateBeta', 1);

  [D,N] = size(data.continuous);
  Dz = size(params.mean,1);
  y = data.continuous;

  % compute posterior distribution
  betaTimesNoisePrecMat = params.beta'*params.noisePrecMat;
  precMatPost = betaTimesNoisePrecMat*params.beta + params.precMat;
  covMatPost = inv(precMatPost);
  meanPost = covMatPost*(bsxfun(@plus, betaTimesNoisePrecMat*y, params.precMat*params.mean));

  % postDist
  if nargout > 2
    postDist.mean = meanPost;
    postDist.precMat = precMatPost;
    postDist.covMat = covMatPost;
  end

  % sufficient statistics
  if computeSs
    ss.sumMean = sum(meanPost,2); 
    ss.sumCovMat = N*covMatPost + meanPost*meanPost';
    if estimateBeta
      ss.sumLhs = y*meanPost';
    else
      ss.sumPhi = sum((y - params.beta*meanPost).^2,2) + N*diag(params.beta*covMatPost*params.beta');
    end
  else
    ss = [];
  end

  % log Lik
  if computeLogLik
    % link
    logLink = sum(logMvnPdfWithMissingData(y, [1:N], params.beta*meanPost, params.noisePrecMat))...
      - 0.5*N*trace(betaTimesNoisePrecMat'*covMatPost*params.beta');
    % latent
    logLatent = sum(logMvnPdfWithMissingData(params.mean, [1:N], meanPost, params.precMat))...
      - 0.5*N*trace(params.precMat*covMatPost);
    % entropy
    entrpy = 0.5*N*(log(2*pi)*Dz + logdet(covMatPost));
    % prior on parameters
    logPrior = - 0.5*params.lambda*trace(params.noisePrecMat*params.beta*params.beta')...
      - (params.a + 1)*sum(log(diag(params.noiseCovMat)))...
      - params.b*sum(diag(params.noisePrecMat));
    logPriot = logPrior + 0.5*(params.nu0+Dz+1)*logdet(params.precMat) - 0.5*trace(params.S0*params.precMat);

    logLik = logLink + logLatent + entrpy + logPrior;
    logLik = logLik/N;
  else
    logLik = [];
  end


