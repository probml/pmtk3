function [ss, logLik, postDist] = inferMixedDataFA(data, params, options)
% [SS, LOGLIK, POSTDIST] = inferMixedDataFA(DATA, PARAMS, []) runs inference for factor
% analysis model with Mixed datatype. See 'help initMixedDataFA' for details on data
% format for DATA and PARAMS. This does not handles missing data. See
% inferMixedDataFA_miss for code that handles missing data.
% 
% POSTDIST has the follwing fields (Dz = #latentFactors, N = #observations),
%    mean        : posterior mean (Dz x N)
%    covMat      : posterior covariance matrix (Dz x Dz x N)
%    precMat     : inv(covMat)
%    psi         : optimized variational params (sum(nClass) x N)
%    y           : 'pseudo' measurements (Dc+sum(nClass) x N)
%    noiseCovMat : 'psuedo' measurement noise covaraince of size Dc+sum(nClass) 
%    noisePrecMat: inv(noiseCovMat)
%    logMult     : scaling factor h(psi) for the lower bound (1 x N)
%    
% SS has the follwing fields (Z are latent factors, y is data, Dc is data dim),
%    sumMean   : sum E(Z) over data points (Dz x 1)
%    sumCovMat : sum E(Z*Z') over data points (Dz x Dz)
%    sumLhs    : sum y*E(Z) over data points (Dc x Dz)
%    sumPhi    : sum of residuals over data points (Dc x 1)
%    psi       : optimized variational params (sum(nClass) x N)
% 
% [SS, LOGLIK, POSTDIST] = inferMixedDataFA(DATA, PARAMS, OPTIONS) specifies options.
% The following OPTIONS can be specified,
%    computeLogLik : 1 if logLik needs to be computed.
%    computeSs     : 1 if SuffStats needs to be computed. 
%    estimateBeta  : 1 if loading factor matrix needs to be estimated.
%
% See testLearnMixedDataFA.m for an example.
% See also : maxParamsMixedDataFA, initMixedDataFA, inferMixedDataFA_miss,
% inferMixedDataFA_jaakkola 
% 
% Written by Emtiyaz, CS, UBC,
% modified on June 09, 2010

  [computeSs, computeLogLik, estimateBeta, maxItersInfer, fixDiag] = myProcessOptions(options, 'computeSs', 1, 'computeLogLik', 1, 'estimateBeta', 1, 'maxItersInfer', 5, 'fixDiag', 0);

  [Dc,Nc] = size(data.continuous);
  [Dm,Nm] = size(data.categorical);
  N = max([Nc Nm]);
  Dz = size(params.mean,1);

  % multinomial variational parameters
  if Dm~=0 
    M = params.nClass-1;
    psi = params.psi;
  else
    M = [];
    psi = [];
  end

  % compute posterior covMat
  BpsiB = 0;
  if Dc ~= 0
    BpsiB = BpsiB + params.betaCont'*params.noisePrecMat*params.betaCont;
  end
  if Dm ~= 0
    for d = 1:length(M)
      idx = sum(M(1:d-1))+1:sum(M(1:d));
      BpsiB = BpsiB + params.betaMult(idx,:)'*params.A{d}*params.betaMult(idx,:);
    end
  end
  precMatPost = BpsiB + params.precMat;
  covMatPost = inv(precMatPost);

  % precompute some quantities
  informLatent = params.precMat*params.mean;
  y = zeros(Dc + sum(M),N);
  noisePrecMat = zeros(Dc + sum(M));
  noiseCovMat = zeros(Dc + sum(M));

  % compute posterior mean
  informLik = 0;
  logMult = 0;
  logMult_n = 0;
  if Dc~=0 
    % continuous measurements
    informLik = informLik + params.betaCont'*bsxfun(@rdivide, data.continuous, diag(params.noiseCovMat));
    y(1:Dc,:) = data.continuous;
    noisePrecMat(1:Dc,1:Dc) = params.noisePrecMat;
    noiseCovMat(1:Dc,1:Dc) = params.noiseCovMat;
    c = 0;
  end
  if Dm ~= 0;
    % multinomial measurements
    % optimize variational params
    for iter = 1:maxItersInfer
      b = [];
      for d = 1:length(M)
        idx = sum(M(1:d-1))+1:sum(M(1:d));
        psi_d = psi(idx,:);
        smPsi = exp(myLogSoftMax([psi_d; zeros(1,N)]));
        Apsi = params.A{d}*psi_d;
        b = [b; Apsi - smPsi(1:end-1,:)];
      end
      informLikMult = params.betaMult'*(data.categorical + b); 
      meanPost = covMatPost*(bsxfun(@plus, informLik + informLikMult, informLatent));
      psiOld = psi;
      psi = params.betaMult*meanPost;
      % convergence
      [converged, incr] = isConverged([psiOld(:)  psi(:)], 1e-5, 'parameter');
      if converged; break; end;
    end
    % update information vector
    informLik = informLik + informLikMult;

    % compute pseudo measurements and contribution to logLik
    for d = 1:length(M)
      idx = sum(M(1:d-1))+1:sum(M(1:d));
      psi_d = psi(idx,:);
      smPsi = exp(myLogSoftMax([psi_d; zeros(1,N)]));
      Apsi = params.A{d}*psi_d;
      smPsi = smPsi(1:end-1,:);
      b = Apsi - smPsi;
      y_m = params.invA{d}*(data.categorical(idx,:) + b);
      y(Dc+idx(1):Dc+idx(end),:) = y_m;
      noisePrecMat(Dc+idx(1):Dc+idx(end),Dc+idx(1):Dc+idx(end)) = params.A{d};
      noiseCovMat(Dc+idx(1):Dc+idx(end),Dc+idx(1):Dc+idx(end)) = params.invA{d};
      c = 0.5*sum(psi_d.*Apsi,1) - sum(smPsi.*psi_d,1) + logsumexp([psi_d; zeros(1,N)]);
      %logMult = logMult + 0.5*N*log(2*pi)*length(idx)...
      %          + 0.5*N*logdet(params.invA{d})...
      %          + 0.5*sum(sum(y_m.*(params.A{d}*y_m))) - sum(c); 
      logMult_n = logMult_n + 0.5*log(2*pi)*length(idx)...
                + 0.5*logdet(params.invA{d})...
                + 0.5*sum(y_m.*(params.A{d}*y_m),1) - c; 
    end
  end
  logMult = sum(logMult_n);
  % compute mean
  meanPost = covMatPost*(bsxfun(@plus, informLik, informLatent));

  % postDist
  if nargout > 2
    postDist.mean = meanPost;
    postDist.precMat = precMatPost;
    postDist.covMat = covMatPost;
    postDist.psi = psi;
    postDist.y = y;
    postDist.noisePrecMat = noisePrecMat;
    postDist.noiseCovMat = noiseCovMat;
    postDist.logMult = logMult_n;
    postDist.c = c;
  end

  % sufficient statistics
  if computeSs
    ss.psi = psi;
    ss.sumMean = sum(meanPost,2); 
    ss.sumCovMat = N*covMatPost + meanPost*meanPost';
    diff = bsxfun(@minus, meanPost, params.mean);
    ss.sumCovMat1 = N*covMatPost + diff*diff';
    if estimateBeta
      ss.sumLhs = y*meanPost';
    end
    if Dc > 0
      ss.sumPhi = sum((data.continuous - params.betaCont*meanPost).^2,2) + N*diag(params.betaCont*covMatPost*params.betaCont');
    end
  else
    ss = 0;
  end

  % log Lik
  logLik = 0;
  if computeLogLik
    % link
    logLink = sum(logMvnPdfWithMissingData(y, [1:N], params.beta*meanPost, noisePrecMat))...
      - 0.5*N*trace(noisePrecMat*params.beta*covMatPost*params.beta');
    % latent
    logLatent = sum(logMvnPdfWithMissingData(params.mean, [1:N], meanPost, params.precMat))...
      - 0.5*N*trace(params.precMat*covMatPost);

    % entropy
    entrpy = 0.5*N*(log(2*pi)*Dz + logdet(covMatPost));

    % prior on parameters
    logPrior = 0;
    if Dc>0
      logPrior = -(params.a + 1)*sum(log(diag(params.noiseCovMat)))...
        - params.b*sum(diag(params.noisePrecMat));
    end
    switch params.priorCovMat
    case 'invWishart'
      logPrior = logPrior + 0.5*(params.nu0+Dz+1)*logdet(params.precMat) - 0.5*trace(params.S0*params.precMat);
    case 'laplace'
      %logPrior = logPrior - 0.5*N*params.lambdaLaplace*sum(sum(abs(setdiag(params.precMat,0))));
      lambda  = params.lambdaLaplace;
      if fixDiag
        logPrior = logPrior - lambda*sum(sum(abs(setdiag(params.precMat,0))));
      else
        logPrior = logPrior - lambda*sum(sum(abs(params.precMat)));
      end
    otherwise
      error('No such prior for covMat');
    end

    logLik = logLink + logLatent + entrpy + logMult + logPrior;
    logLik = logLik/N;
  end

