function params = maxParamsGmm(ss, data, params, options)
% Maximize params for IMM (doesn't work for missing data right now)
% written by Emtiyaz, CS, UBC
% Modified on April 08, 2010

  [Dc,N] = size(data.continuous);
  [Dd,N] = size(data.discrete);
  if isfield(options, 'regCovMat')
    regCovMat = options.regCovMat;
  else
    regCovMat = 0;
  end
  for k = 1:length(ss.resp)
    % params for continuous measurements
    if Dc ~= 0
      params.mean(:,k) = ss.sumY(:,k)/ss.resp(k);
      switch options.covMat
      case 'diag'
        if regCovMat
          den = params.nu0(k) + size(data.continuous,1) + 1 + ss.resp(k);
          params.covMat(:,:,k) = (params.S0(:,:,k) + diag(ss.sumYY(:,k)))./den ...
              -(ss.resp(k)/den)*diag(params.mean(:,k).*params.mean(:,k));
        else
          params.covMat(:,:,k) = diag(ss.sumYY(:,k)/ss.resp(k) - params.mean(:,k).*params.mean(:,k));
        end
      case 'full'
        if regCovMat
          den = params.nu0(k) + size(data.continuous,1) + 1 + ss.resp(k);
          params.covMat(:,:,k) = (params.S0(:,:,k) + ss.sumYY(:,:,k))./den ...
              -(ss.resp(k)/den)*params.mean(:,k)*params.mean(:,k)';
        else
          params.covMat(:,:,k) = ss.sumYY(:,:,k)/ss.resp(k) - params.mean(:,k)*params.mean(:,k)';
        end
        params.precMat(:,:,k) = inv(params.covMat(:,:,k));
        params.logDetPrecMat(k) = logdet(params.precMat(:,:,k));
      end
    end
    % params for discrete measurements
    if Dd ~=0
      params.prob(:,k) = ss.sumCount(:,k)/ss.resp(k);
    end
  end
  % mixProb parameter
  params.mixProb = ss.resp./sum(ss.resp);
  params.mixProb = params.mixProb(:);
  params.logMixProb = log(max(params.mixProb,eps));
