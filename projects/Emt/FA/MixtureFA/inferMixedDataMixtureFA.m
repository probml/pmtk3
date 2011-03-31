function [ss, logLik, postDist] = inferMixedDataMixtureFA(data, params, options)
% inference for mixture of FAs with for mixed data types

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
    [ss_temp, logLik_temp, postDistK] = inferMixedDataFA(data, paramsK, struct('computeSs',0, 'computeLogLik',0, 'maxItersInfer', options.maxItersInfer));
    meanPost(:,:,k) = postDistK.mean;
    covMatPost(:,:,k) = postDistK.covMat;
    precMatPost(:,:,k) = postDistK.precMat;
    logMult(k,:) = postDistK.logMult;
    y(:,:,k) = postDistK.y;
    noisePrecMat = postDistK.noisePrecMat;
    noiseCovMat = postDistK.noiseCovMat;
    psi(:,:,k) = postDistK.psi;

    % postDist of mixing variable
    mean_ = params.beta(:,:,k)*params.mean(:,k);
    precMat = inv(noiseCovMat + params.beta(:,:,k)*params.covMat(:,:,k)*params.beta(:,:,k)');
    logMixProbPost(k,:) = logMult(k,:) + log(max(params.mixProb(k),eps)) + logMvnPdfWithMissingData(y(:,:,k), [1:N], mean_, precMat);
  end
  % normalize
  mixProbPost = exp(bsxfun(@minus, logMixProbPost, logsumexp(logMixProbPost, 1)));

  % postDist
  if nargout > 2
    postDist.mean = meanPost;
    postDist.precMat = precMatPost;
    postDist.covMat = covMatPost;
    postDist.mixProb = mixProbPost;
    postDist.psi = psi;
  end

  sumMixProb = sum(mixProbPost,2);
  % sufficient statistics
  if options.computeSs
    ss.psi = psi;
    ss.sumMixProb = sumMixProb;
    ss.sumPhi = 0;
    if Dc >0
      Yc2 = data.continuous.^2;
    end
    for k = 1:K
      mixProbTimesMeanPost(:,:,k) = bsxfun(@times, mixProbPost(k,:), meanPost(:,:,k));
      ss.sumMean(:,k) = sum(mixProbTimesMeanPost(:,:,k),2); 
      ss.sumCovMat(:,:,k) = covMatPost(:,:,k)*ss.sumMixProb(k) + mixProbTimesMeanPost(:,:,k)*meanPost(:,:,k)';
      if options.estimateBeta
        ss.sumLhs(:,:,k) = y(:,:,k)*mixProbTimesMeanPost(:,:,k)';
        if Dc>0
          ss.sumYY(:,k) = sum(bsxfun(@times, mixProbPost(k,:), Yc2),2);
        end
      else
        if Dc >0
          err = (data.continuous - params.betaCont(:,:,k)*meanPost(:,:,k)).^2;
          err = bsxfun(@times, mixProbPost(k,:), err);
          ss.sumPhi = ss.sumPhi + sum(err,2) + ss.sumMixProb(k)*diag(params.betaCont(:,:,k)*covMatPost(:,:,k)*params.betaCont(:,:,k)');
        end
      end
    end
  else
    ss = 0;
  end

  % log Lik
  logLik = 0;
  if options.computeLogLik == 1
    for k = 1:K
      % logLink
      logLink_k = logMvnPdfWithMissingData(y(:,:,k), [1:N], params.beta(:,:,k)*meanPost(:,:,k), noisePrecMat);
      logLink = sum(mixProbPost(k,:).*logLink_k,2)...
        - 0.5*sumMixProb(k)*trace(noisePrecMat*params.beta(:,:,k)*covMatPost(:,:,k)*params.beta(:,:,k)');
      % logLatent
      logLatent_k = logMvnPdfWithMissingData(params.mean(:,k), [1:N], meanPost(:,:,k), params.precMat(:,:,k));
      logLatent = sum(mixProbPost(k,:).*logLatent_k, 2)...
        - 0.5*sumMixProb(k)*trace(params.precMat(:,:,k)*covMatPost(:,:,k));
      % log Mult
      % logMixVariable
      logMixVar = sumMixProb(k)*log(max(params.mixProb(k),eps));
      % entropy
      entrpy = sumMixProb(k)*(0.5*(log(2*pi)*Dz + logdet(covMatPost(:,:,k))))...
                - sum(mixProbPost(k,:).*log(max(mixProbPost(k,:),eps)),2);
     
      logLik = logLik + logLink + logLatent + logMixVar + entrpy;

      if options.regCovMat == 1
        logLik = logLik + 0.5*(params.nu0+Dz+1)*logdet(params.precMat(:,:,k)) - 0.5*trace(params.S0*params.precMat(:,:,k));
      end
    end
    logLik = logLik + sum(sum(mixProbPost.*logMult));
    logPrior = 0;
    if Dc >0
      logPrior = - (params.a + 1)*sum(log(diag(params.noiseCovMat)))...
        - params.b*sum(diag(params.noisePrecMat));
    end
    logPrior = logPrior + params.alpha0*sum(log(max(params.mixProb,eps)));
    logLik = logLik + logPrior;
    logLik = logLik/(N*K);
  end


