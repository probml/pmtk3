function [ss, logLik, postDist] = inferImm(data, params, options)
% inference for Imm
% doesn't work with missing data for learning (but for inference it does)

  K = length(params.mixProb);
  [Dc,Nc] = size(data.continuous);
  [Dd,Nd] = size(data.discrete);
  N = max(Nc,Nd);

  logLikNorm = 0;
  logLikDiscrete = 0;

  for k = 1:K
    % continuous measurements
    if Dc ~= 0
      logLikNorm = logMvnPdfWithMissingData(data.continuous, data.obs, params.mean(:,k), params.precMat(:,:,k), params.logDetPrecMat(k), params.covMat(:,:,k));
    end
    % discrete measurements
    if Dd ~=0
      % sum(Y.*log(prob(d,1:C,k))
      logLikDiscrete = sum(bsxfun(@times, data.discrete, params.logProb(:,k)));
    end
    logMixProb(k,:) = params.logMixProb(k) + logLikNorm + logLikDiscrete;
  end
  % normalize
  logMixProbNormalized = bsxfun(@minus, logMixProb, logsumexp(logMixProb,1));
  mixProb = exp(logMixProbNormalized);
  if nargout > 2
    postDist.mixProb = mixProb;
  end

  % sufficient statistics
  if options.computeSs
    if data.containsMissingData
      data.continuous(isnan(data.continuous)) = 0;
    end
    ss.resp = sum(mixProb,2);
    for k = 1:K
      if Dc ~= 0
        ss.sumY(:,k) = sum(bsxfun(@times, mixProb(k,:), data.continuous),2); 
        switch options.covMat
        case 'diag'
          ss.sumYY(:,k) = sum(bsxfun(@times, mixProb(k,:), data.continuous.^2),2); 
        case 'full'
          ss.sumYY(:,:,k) = bsxfun(@times, mixProb(k,:), data.continuous)*data.continuous'; 
        end
      end
      if Dd ~=0
        ss.sumCount(:,k) = sum(bsxfun(@times, data.discrete, mixProb(k,:)), 2);
      end
    end
  else
    ss = 0;
  end

  % log Lik
  logLik = 0;
  if options.computeLogLik == 1
    logLik = sum(sum(mixProb.*(logMixProb - logMixProbNormalized)));
    if Dc>0
      if options.regCovMat == 1
        for k = 1:K
          logLik = logLik + 0.5*(params.nu0(k)+Dc+1)*params.logDetPrecMat(k) - 0.5*trace(params.S0(:,:,k)*params.precMat(:,:,k));
        end
      end
    end
  end
  logLik = logLik/N;


