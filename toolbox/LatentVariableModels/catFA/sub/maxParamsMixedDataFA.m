function params = maxParamsMixedDataFA(ss, data, params, options)
% PARAMS = maxParamsMixedDataFA(SS, DATA, PARAMS, []) same as 'maxParamsFA' but
%   for mixed datatype. It is compatible with the following inference functions :
%   inferMixedDataFA, inferMixedDataFA_miss, inferMixedDataFA_jaakkola.
%   This function also handles missing data.
% 
% See testLearnMixedDataFA.m for an example.
% See also : initMixedDataFA, inferMixedDataFA, inferMixedDataFA_miss, inferMixedDataFA_jaakkola
% 
% Written by Emtiyaz, CS, UBC,
% modified on June 09, 2010

  [Db,Nb] = size(data.binary);
  [Dm,Nm] = size(data.categorical);
  [Dc,Nc] = size(data.continuous);
  N = max([Nb Nc Nm]);
  Dz = size(params.mean,1);

  [estimateMean, estimateBeta, estimateCovMat, estimateNoiseCovMat] = myProcessOptions(options, 'estimateMean', 1, 'estimateBeta', 1, 'estimateCovMat', 0, 'estimateNoiseCovMat', 1);

  % missing data?
  missing = sum(sum(isnan([data.continuous; data.binary; data.categorical])));
  if Dc>0
    idxMiss = isnan(data.continuous);
    idxObs = ~idxMiss;
    Nobs = sum(idxObs,2);
  end

  % mean and CovMat
  den = params.nu0 + Dz + 1 + N;
  if estimateMean
    params.mean = ss.sumMean/N;
    if estimateCovMat
      params.covMat = (params.S0 + ss.sumCovMat)/den - N*params.mean*params.mean'/den;
      params.precMat = inv(params.covMat);
    end
  else 
    if estimateCovMat
      params.covMat = (params.S0 + ss.sumCovMat1)/den;
      params.precMat = inv(params.covMat);
    end
  end

  % beta and Phi
  if estimateBeta
    if missing
      params.beta = ss.beta;
    else
      params.beta = ss.sumLhs*inv(ss.sumCovMat);
    end
    if Dc > 0
      %params.beta(1:Dc,:) = params.betaCont(1:Dc,:);
      params.betaCont = params.beta(1:Dc,:);
      params.noiseCovMat = diag((2*params.b + data.YY - diag(params.betaCont*ss.sumLhs(1:Dc,:)'))./(Nobs(:) + 2*(params.a + 1)));
      params.noisePrecMat = diag(1./diag(params.noiseCovMat));
    end
    if Db > 0
      params.betaBin = params.beta(Dc+1:Dc+Db,:);
    end
    if Dm > 0
      params.betaMult = params.beta(Dc+Db+1:end,:);
    end
  else
    if Dc > 0
      if estimateNoiseCovMat
        numl = ss.sumPhi + 2*params.b;
        params.noiseCovMat = diag(numl./(Nobs + 2*(params.a + 1)));
        params.noisePrecMat = diag(1./diag(params.noiseCovMat));
      end
    end
  end
  % variational params
  if Dm > 0
    params.psi = ss.psi;
  end
  if Db > 0
    params.xi = ss.xi;
  end

