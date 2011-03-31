function params = maxParamsMixtureFA(ss, data, params, options)

  [D,N] = size(data.continuous);
  [Dz,K] = size(params.mean);

  params.mixProb = ss.sumMixProb/sum(ss.sumMixProb);
  params.mean = bsxfun(@times, ss.sumMean, 1./ss.sumMixProb(:)');

  t = 0;
  for k = 1:K
    if options.estimateCovMat
      % haven't chcked this part yet
      if ~options.regCovMat
        params.covMat(:,:,k) = ss.sumCovMat(:,:,k)/ss.sumMixProb(k) - params.mean(:,k)*params.mean(:,k)';
      else
        den = params.nu0 + Dz + 1 + ss.sumMixProb(k);
        params.covMat(:,:,k) = (params.S0 + ss.sumCovMat(:,:,k))/den - N*params.mean*params.mean'/den;
      end
      params.precMat(:,:,k) = inv(params.covMat(:,:,k));
    end

    % beta
    if options.estimateBeta
      params.beta(:,:,k) = ss.sumLhs(:,:,k)*inv(ss.sumCovMat(:,:,k));
      t = t + ss.sumYY(:,k) - diag(params.beta(:,:,k)*ss.sumLhs(:,:,k)'); % for Phi
    end
  end

  % noise variance
  if options.estimateBeta
    params.noiseCovMat = diag(2*params.b + t)./(N + 2*(params.a + 1));
  else
    numl = ss.sumPhi + 2*params.b;
    params.noiseCovMat = diag(numl./(N + 2*(params.a + 1)));
  end
  params.noisePrecMat = diag(1./diag(params.noiseCovMat));

