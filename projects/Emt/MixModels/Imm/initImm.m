function [params, data] = initImm(data, params, options)
% initialize IMM params
% written by Emtiyaz, CS, UBC
% Modified on April 08, 2010
  
  [initMethod, scale, numOfMix, encodeDataOneOfM, s0, refine, nClass] = myProcessOptions(options, 'initMethod', 'random', 'scale', 2, 'numOfMix',2, 'encodeDataOneOfM', 0, 's0', 1, 'refine', 0, 'nClass', []);

  [Dc,Nc] = size(data.continuous);
  [Dd,Nd] = size(data.discrete);
  if Dc == 0
    N = Nd;
  elseif Dd == 0
    N = Nc;
  else
    N = Nc;
  end
  K = numOfMix;
  % mixing probability
  t = rand(K,1);
  params.mixProb = t/sum(t);
  params.logMixProb = log(max(params.mixProb,eps));

  % gaussian parameters
  if Dc ~= 0
    % set regularization parameters for covMat
    params.S0 = bsxfun(@times, s0*eye(Dc),ones(1,1,K));
    params.nu0 = Dc*ones(K,1) + 2;
    params.mean = scale*randn(Dc,K);
    params.covMat = bsxfun(@times, eye(Dc,Dc), ones(1,1,K));
    for k = 1:K
      params.precMat(:,:,k) = inv(params.covMat(:,:,k));
      params.logDetPrecMat(k) = logdet(params.precMat(:,:,k));
    end
  end
  % discrete parameters
  if Dd ~= 0
    % prob parameters
    params.prob = [];
    params.nClass = nClass;
    for d = 1:length(nClass)
      idx = sum(nClass(1:d-1))+1:sum(nClass(1:d-1))+nClass(d);
      for k = 1:K
        p = rand(nClass(d), 1); 
        p = p./sum(p);
        params.prob(idx, k) = p;
      end
    end
    params.logProb = log(params.prob);
    params.nClass = nClass;
    % encode data to one of M
    if encodeDataOneOfM
      data.discreteNew = [];
      for d = 1:Dd
        data.discreteNew(end+1:end+params.nClass(d),:) = bsxfun(@eq, data.discrete(d,:), [1:params.nClass(d)]');
      end
      data.discrete = data.discreteNew;
      data = rmfield(data, 'discreteNew');
    end
  end

  % missing data?
  idxObs = isnan(data.continuous);
  data.containsMissingData = sum(idxObs(:));
  data.miss = find(sum(idxObs));
  data.obs = find(sum(idxObs)==0);

  if refine
    idx = randperm(N);
    params.mean = data.continuous(:,idx(1:K));
    idx = randperm(N);
    idx = idx(1:ceil(N/20));
    if Dc~=0
      dataNew.continuous = data.continuous(:,idx);
    else
      dataNew.discrete = [];
    end
    if Dd~=0
      dataNew.discrete = data.discrete(:,idx);
    else
      dataNew.discrete = [];
    end
    idxObs = isnan(dataNew.continuous);
    dataNew.containsMissingData = sum(idxObs(:));
    dataNew.miss = find(sum(idxObs));
    dataNew.obs = find(sum(idxObs)==0);

    options = struct('maxNumOfItersLearn', 10, 'regCovMat', 1, 'display',0, 'covMat', 'diag');
    funcName = struct('inferFunc', @inferImm, 'maxParamsFunc', @maxParamsImm);
    [params, logLik] = learnEm(dataNew, funcName, params, options);
  end

