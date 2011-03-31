function [ss, logLik, postDist] = inferMixtureFA(data, params, options)
% inference for mixture of FAs with missing values

  [D,N] = size(data.continuous);
  [Dz,K] = size(params.mean);

  y = data.continuous;

  % compute postDist
  for k = 1:K
    % run FA for each mixture component
    params_k = params;
    params_k.covMat = params.covMat(:,:,k);
    params_k.precMat = params.precMat(:,:,k);
    params_k.mean = params.mean(:,k);
    params_k.beta = params.beta(:,:,k);

    [ss_temp, logLik_temp, postDistK] = inferFA(data, params_k, struct('computeSs',0, 'computeLogLik',0));
    meanPost(:,:,k) = postDistK.mean;
    covMatPost(:,:,k) = postDistK.covMat;

    % postDist of mixing variable
    mean_ = params.beta(:,:,k)*params.mean(:,k);
    precMat = inv(params.noiseCovMat + params.beta(:,:,k)*params.covMat(:,:,k)*params.beta(:,:,k)');
    logMixProbPost(k,:) = log(params.mixProb(k)) + logMvnPdfWithMissingData(y, [1:N], mean_, precMat);
  end
  % normalize
  mixProbPost = exp(bsxfun(@minus, logMixProbPost, logsumexp(logMixProbPost, 1)));

  % postDist
  if nargout > 2
    postDist.mean = meanPost;
    postDist.precMat = precMatPost;
    postDist.covMat = covMatPost;
    postDist.mixProb = mixProbPost;
  end

  sumMixProb = sum(mixProbPost,2);
  % sufficient statistics
  if options.computeSs
    Y2 = y.^2;
    ss.sumMixProb = sumMixProb;
    ss.sumPhi = 0;
    for k = 1:K
      mixProbTimesMeanPost(:,:,k) = bsxfun(@times, mixProbPost(k,:), meanPost(:,:,k));
      ss.sumMean(:,k) = sum(mixProbTimesMeanPost(:,:,k),2); 
      ss.sumCovMat(:,:,k) = covMatPost(:,:,k)*ss.sumMixProb(k) + mixProbTimesMeanPost(:,:,k)*meanPost(:,:,k)';
      if options.estimateBeta
        ss.sumLhs(:,:,k) = y*mixProbTimesMeanPost(:,:,k)';
        ss.sumYY(:,k) = sum(bsxfun(@times, mixProbPost(k,:), Y2),2);
      else
        err = (y - params.beta(:,:,k)*meanPost(:,:,k)).^2;
        err = bsxfun(@times, mixProbPost(k,:), err);
        ss.sumPhi = ss.sumPhi + sum(err,2) + ss.sumMixProb(k)*diag(params.beta(:,:,k)*covMatPost(:,:,k)*params.beta(:,:,k)');
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
      logLink_k = logMvnPdfWithMissingData(y, [1:N], params.beta(:,:,k)*meanPost(:,:,k), params.noisePrecMat);
      logLink = sum(mixProbPost(k,:).*logLink_k,2)...
        - 0.5*sumMixProb(k)*trace(params.noisePrecMat*params.beta(:,:,k)*covMatPost(:,:,k)*params.beta(:,:,k)');
      % logLatent
      logLatent_k = logMvnPdfWithMissingData(params.mean(:,k), [1:N], meanPost(:,:,k), params.precMat(:,:,k));
      logLatent = sum(mixProbPost(k,:).*logLatent_k, 2)...
        - 0.5*sumMixProb(k)*trace(params.precMat(:,:,k)*covMatPost(:,:,k));
      % logMixVariable
      logMixVar = sumMixProb(k)*log(params.mixProb(k));
      % entropy
      entrpy = sumMixProb(k)*(0.5*(log(2*pi)*Dz + logdet(covMatPost(:,:,k))))...
                - sum(mixProbPost(k,:).*log(mixProbPost(k,:)),2);
     
      logLik = logLik + logLink + logLatent + logMixVar + entrpy;

      if options.regCovMat == 1
        logLik = logLik + 0.5*(params.nu0+Dz+1)*logdet(params.precMat(:,:,k)) - 0.5*trace(params.S0*params.precMat(:,:,k));
      end
    end
    % prior
    logPrior = - (params.a + 1)*sum(log(diag(params.noiseCovMat)))...
      - params.b*sum(diag(params.noisePrecMat));
    logLik = logLik + logPrior;

    logLik = logLik/(N*K);
  end


