function [ss, logLik, postDist] = inferGmm_ver1(data, params, options)
% inference for Gmm

  y = data.continuous;
  [D,K] = size(params.mean);
  [D,N] = size(y);
  % posterior distribution
  for k = 1:K
    logNorm = logMvnPdfWithMissingData(y, data.obs, params.mean(:,k), params.precMat(:,:,k), params.logDetPrecMat(k), params.covMat(:,:,k));
    logMixProb(k,:) = params.logMixProb(k) + logNorm;
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
      y(isnan(y)) = 0;
    end
    ss.resp = sum(mixProb,2);
    for k = 1:K
      ss.sumY(:,k) = sum(bsxfun(@times, mixProb(k,:), y),2); 
      ss.sumYY(:,:,k) = bsxfun(@times, mixProb(k,:), y)*y'; 
    end
  else
    ss = 0;
  end

  % log Lik
  if options.computeLogLik == 1
    %logLik = sum(log(sum(exp(logMixProb))),2);
    logLik = sum(sum(mixProb.*(logMixProb - logMixProbNormalized)));
    if options.regCovMat == 1
      for k = 1:K
        logLik = logLik + 0.5*(params.nu0(k)+D+1)*params.logDetPrecMat(k) - 0.5*trace(params.S0(:,:,k)*params.precMat(:,:,k));
      end
    end
  end

function val = myLogNormPdf(y, covMat) 
% compute lognormpdf, call this inside cellfun
  i = find(~isnan(y));
  val = -0.5*length(i)*log(2*pi) - 0.5*(logdet(covMat(i,i))) - 0.5*y(i)'*inv(covMat(i,i))*y(i); 

