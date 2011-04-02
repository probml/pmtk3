function dataPred = imputeMissingGmm(data, params, options);

  dataPred = data;
  [D,K] = size(params.mean);
  [D,N] = size(data);
  for n = 1:N
    idxMiss = find(isnan(data(:,n)));
    idxObs = find(~isnan(data(:,n)));
    if ~isempty(idxMiss)
      [varDist, logLik_n] = inferGmm(data(:,n), params, options);
      varDist.mixProb
      for k = 1:K
        pred(:,k) = params.mean(idxMiss,k) + params.covMat(idxMiss,idxObs,k)*inv(params.covMat(idxObs,idxObs,k))*(data(idxObs,n) - params.mean(idxObs,k));
      end
      dataPred(idxMiss,n) = sum(pred.*repmat(varDist.mixProb(:)',length(idxMiss),1),2);
      clear pred;
    end
  end
