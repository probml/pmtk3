function [params, data] = initGmm(data, params, options)
% initialize GMM params
% written by Emtiyaz, CS, UBC
% Modified on April 05, 2010
  
  [initMethod, scale, numOfMix] = myProcessOptions(options, 'initMethod', 'random', 'scale', 2, 'numOfMix',2);

  [D,N] = size(data.continuous);
  K = numOfMix;
  % set regularization parameters for covMat
  if ~isfield(params,'S0')
    params.S0 = bsxfun(@times, eye(D),ones(1,1,K));
  end
  if ~isfield(params,'nu0')
    params.nu0 = D*ones(K,1) + 2;
  end

  switch initMethod
  case 'random'
    % random initialization
    if ~isfield(params,'mean')
      params.mean = scale*randn(D,K);
    end
    if ~isfield(params,'covMat')
      L = randn(D,D);
      params.covMat = bsxfun(@times, L'*L, ones(1,1,K));
      for k = 1:K
        params.precMat(:,:,k) = inv(params.covMat(:,:,k));
        params.logDetPrecMat(k) = logdet(params.precMat(:,:,k));
      end
    end
    if ~isfield(params,'mixProb')
      t = rand(K,1);
      params.mixProb = t/sum(t);
    end
    params.logMixProb = log(max(params.mixProb,eps));
  end

  % missing data?
  idxObs = isnan(data.continuous);
  data.containsMissingData = sum(idxObs(:));
  data.miss = find(sum(idxObs));
  data.obs = find(sum(idxObs)==0);


