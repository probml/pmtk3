function [ss, logLik, postDist] = inferMixedDataMixtureFA_miss(data, params, options)
% inference for mixture of FAs with for mixed data types
% Computation of SS and logLik are not implemented right now
% To save memory covMatPost is not saved right now, uncomment that line if
% covMatPost is needed

  [Dc,Nc] = size(data.continuous);
  [Dm,Nm] = size(data.categorical);
  N = max([Nc Nm]);
  [Dz,K] = size(params.mean);

  % multinomial variational parameters
  if Dm>0 
    M = params.nClass-1;
    psi = params.psi;
  else
    M = [];
    psi = [];
  end

  % missing data?
  idxObs = isnan([data.continuous; data.categorical]);
  miss = find(sum(idxObs));
  obs = find(sum(idxObs)==0);

  for k = 1:K
    % run inferMixedDataFA for mixture component K
    paramsK = params;
    paramsK.covMat = params.covMat(:,:,k);
    paramsK.precMat = params.precMat(:,:,k);
    paramsK.mean = params.mean(:,k);
    paramsK.beta = params.beta(:,:,k);
    if Dm>0
      paramsK.betaMult = params.betaMult(:,:,k);
      paramsK.psi = params.psi(:,:,k);
    end
    if Dc>0
      paramsK.betaCont = params.betaCont(:,:,k);
    end
    [ss_temp, logLik_temp, postDistK] = inferMixedDataFA_miss(data, paramsK, struct('computeSs',0, 'computeLogLik',0, 'maxItersInfer', 5));
    meanPost(:,:,k) = postDistK.mean;
    %covMatPost(:,:,:,k) = postDistK.covMat;
    %precMatPost(:,:,:,k) = postDistK.precMat;
    logMult(k,:) = postDistK.logMult;
    y(:,:,k) = postDistK.y;
    noisePrecMat = postDistK.noisePrecMat;
    noiseCovMat = postDistK.noiseCovMat;
    %psi(:,:,k) = postDistK.psi;

    % postDist of mixing variable
    mean_ = params.beta(:,:,k)*params.mean(:,k);
    precMat = inv(noiseCovMat + params.beta(:,:,k)*params.covMat(:,:,k)*params.beta(:,:,k)');
    logMixProbPost(k,:) = logMult(k,:) + log(params.mixProb(k)) + logMvnPdfWithMissingData(y(:,:,k), obs, mean_, precMat);
  end
  % normalize
  mixProbPost = exp(bsxfun(@minus, logMixProbPost, logsumexp(logMixProbPost, 1)));

  % postDist
  if nargout > 2
    postDist.mean = meanPost;
    %postDist.precMat = precMatPost;
    %postDist.covMat = covMatPost;
    postDist.mixProb = mixProbPost;
    %postDist.psi = psi;
  end

  ss = 0;
  logLik = 0;


