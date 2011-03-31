function params = maxParamsSparseLGM(ss, data, params, options)
% PARAMS = maxParamsSparseLGM(SS, DATA, PARAMS, []) same as 'maxParamsMixedDataFA' but
%   for specifically for a sparse LGM. It is compatible with the following inference functions :
%   inferMixedDataFA, inferMixedDataFA_miss, inferMixedDataFA_jaakkola.
% 
% See testLearnSparseLGM.m for an example.
% See also : initMixedDataFA, inferMixedDataFA, inferMixedDataFA_miss, inferMixedDataFA_jaakkola
% 
% Written by Emtiyaz, CS, UBC,
% modified on September 20, 2010
%
% TODO Include missing data, parallelize update of beta

  [Db,Nb] = size(data.binary);
  [Dm,Nm] = size(data.categorical);
  [Dc,Nc] = size(data.continuous);
  N = max([Nb Nc Nm]);
  Dz = size(params.mean,1);

  [estimateMean, estimateBeta, estimateCovMat, estimateNoiseCovMat, fixDiag, l1GeneralMaxIter, l1GeneralFunEvals] = myProcessOptions(options, 'estimateMean', 1, 'estimateBeta', 0, 'estimateCovMat', 1, 'estimateNoiseCovMat', 1, 'fixDiag', 0, 'l1GeneralMaxIter', 500, 'l1GeneralFunEvals', 500);

  if ~isfield(params, 'priorCovMat')
    params.priorCovMat = 'laplace'
    params.lambdaLaplace = 0;
  end

  % missing data?
  missing = sum(sum(isnan([data.continuous; data.binary; data.categorical])));
  if Dc>0
    idxMiss = isnan(data.continuous);
    idxObs = ~idxMiss;
    Nobs = sum(idxObs,2);
  end

  % mean
  den = N;
  if estimateMean
    params.mean = ss.sumMean/N;
    if estimateCovMat
      sigma_emp = ss.sumCovMat/N - params.mean*params.mean';
    end
  else
    if estimateCovMat
      sigma_emp = ss.sumCovMat1/N;
    end
  end

  % CovMat
  if estimateCovMat
    switch params.priorCovMat
    case 'laplace'
      if params.lambdaLaplace
        if fixDiag
          nonZero = find(setdiag(ones(Dz),0));
          lambdaMat = 2*params.lambdaLaplace*ones(Dz*Dz - Dz,1)/N;
        else
          nonZero = find(ones(Dz));
          lambdaMat = 2*params.lambdaLaplace*ones(Dz*Dz,1)/N;
        end
        Ksparse = params.precMat; % warm startinv(sigma_emp);%
        funObj = @(x)sparsePrecisionObj(x,Dz,nonZero,sigma_emp);
        optL1general = struct('order', -1, 'verbose', 0, 'maxIter', l1GeneralMaxIter, 'funEvals', l1GeneralFunEvals,'optTol',1e-6,'threshold',1e-6);
        Ksparse(nonZero) = L1GeneralProjection(funObj,Ksparse(nonZero), lambdaMat, optL1general);
        params.precMat = Ksparse;
        params.covMat = inv(Ksparse);
      else
        params.covMat = sigma_emp;
        params.precMat = inv(sigma_emp);
      end
    case 'invWishart'
      den = params.nu0 + Dz + 1 + N;
      params.covMat = (params.S0 + N*sigma_emp)/den;
      params.precMat = inv(params.covMat);
    otherwise
      error('no priorCovMat specified');
    end
  end

  % beta 
  if estimateBeta
    if missing
      params.beta = ss.beta;
    else
      if Dc >0
        for d = 1:Dc
          params.beta(d,d) = (ss.sumLhs(d,d))/ss.sumCovMat(d,d);
        end
      end
      if Db >0
        for d = Dc+1:Dc+Db
          params.beta(d,d) = (ss.sumLhs(d,d))/ss.sumCovMat(d,d);
        end
      end
      if Dm >0 
        M = params.nClass-1;
        for d = 1:length(params.nClass)
          l = Dc + d;
          idx = sum(M(1:d-1))+1:sum(M(1:d));
          idx = idx + Dc;
          params.beta(idx,l) = (ss.sumLhs(idx,l))/ss.sumCovMat(l,l);
        end
      end
    end
    if Dc > 0
      params.betaCont = params.beta(1:Dc,:);
      if estimateNoiseCovMat
        params.noiseCovMat = diag((2*params.b + data.YY - diag(params.betaCont*ss.sumLhs(1:Dc,:)'))./(Nobs(:) + 2*(params.a + 1)));
        params.noisePrecMat = diag(1./diag(params.noiseCovMat));
      end
    end
    if Db > 0
      params.betaBin = params.beta(Dc+1:Dc+Db,:);
    end
    if Dm > 0
      params.betaMult = params.beta(Dc+Db+1:end,:);
    end
  end

  % estimate Phi
  if Dc > 0
    if estimateNoiseCovMat & ~estimateBeta
      numl = ss.sumPhi + 2*params.b;
      params.noiseCovMat = diag(numl./(Nobs + 2*(params.a + 1)));
      params.noisePrecMat = diag(1./diag(params.noiseCovMat));
    end
  end

  % variational params
  if Dm > 0
    params.psi = ss.psi;
  end
  if Db > 0
    params.xi = ss.xi;
  end

