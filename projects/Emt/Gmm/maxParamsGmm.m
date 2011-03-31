function params = maxParamsGmm(ss, data, params, options)
% Maximize params for GMM
% written by Emtiyaz, CS, UBC
% Modified on April 05, 2010
% doesn't work for missing variables 

  if isfield(options, 'regCovMat')
    regCovMat = options.regCovMat;
  else
    regCovMat = 0;
  end
  for k = 1:length(ss.resp)
    params.mean(:,k) = ss.sumY(:,k)/ss.resp(k);
    if regCovMat
      den = params.nu0(k) + size(data,1) + 1 + ss.resp(k);
      params.covMat(:,:,k) = (params.S0(:,:,k) + ss.sumYY(:,:,k))./den ...
          -(ss.resp(k)/den)*params.mean(:,k)*params.mean(:,k)';
    else
      params.covMat(:,:,k) = ss.sumYY(:,:,k)/ss.resp(k) - params.mean(:,k)*params.mean(:,k)';
    end
    params.precMat(:,:,k) = inv(params.covMat(:,:,k));
    params.logDetPrecMat(k) = logdet(params.precMat(:,:,k));
  end
  params.mixProb = ss.resp./sum(ss.resp);
  params.mixProb = params.mixProb(:);
  params.logMixProb = log(max(params.mixProb,eps));
