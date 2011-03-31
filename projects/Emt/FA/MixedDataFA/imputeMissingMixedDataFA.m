function [data, logLik] = imputeMissingMixedDataFA(data, params, options)
% older file for imputing missing values in MixedDataFA
% new version is imputeMissingMixedDataFA_ver1.m

  [Dc,Nc] = size(data.continuous);
  [Dm,Nm] = size(data.categorical);
  N = max(Nc, Nm);

  options.maxItersInfer = 10;

  options.computeSs = 0;
  options.computeLogLik = 1;
  logLik = 0;
  for n = 1:N
    % format parameters and data
    params_n = params;
    if ~isempty(data.categorical)
      params_n.psi = randn(sum(params.nClass-1),1);
      data_n.categorical = data.categorical(:,n);
    else
      data_n.categorical = [];
    end
    data_n.binary = [];
    % remove missing data 
    iMissC = isnan(data.continuous(:,n));
    if ~isempty(iMissC)
      data_n.continuous = data.continuous(~iMissC,n);
      params_n.betaCont = params_n.betaCont(~iMissC,:);
      params_n.beta = params_n.betaCont;
      if Dm~=0
        params_n.beta = [params_n.beta; params_n.betaMult];
      end
      params_n.noiseCovMat = params_n.noiseCovMat(~iMissC,~iMissC);
      params_n.noisePrecMat = params_n.noisePrecMat(~iMissC,~iMissC);
      % inference
      [ss, logLik_n, postDist] = inferMixedDataFA(data_n, params_n, options);
      % impute
      data.continuous(iMissC,n) = params.betaCont(iMissC,:)*postDist.mean;
      logLik = logLik + logLik_n;
    end
  end


