function [pred, logLik] = imputeMissingImm(data, params, options)
% impute missing values for Imm. 

  [Dc,Nc] = size(data.continuous);
  [Dd,Nd] = size(data.discrete);
  N = max(Nd,Nc);
  K = size(params.mixProb,1);

  if Dc >0
    idxObs = isnan(data.continuous);
    data.containsMissingData = sum(idxObs(:));
    data.miss = find(sum(idxObs));
    data.obs = find(sum(idxObs)==0);
  end
  if Dd>0
    miss = isnan(data.discrete);
    data.discrete(miss) = 0;
  end

  % compute postDist
  options.computeSs = 0;
  options.computeLogLik = 1;
  [ss, logLik, postDist] = inferImm(data, params, options);

  % predict continuous
  if Dc > 0
    dataNew = zeros(Dc,Nc);
    for k = 1:K
      dataPred = cellfun(@(y)predictGauss(y, params.mean(:,k), params.covMat(:,:,k)), mat2cell(data.continuous, Dc, ones(1,Nc)), 'uniformoutput',0);
      dataPred = cell2mat(dataPred);
      dataNew = dataNew + bsxfun(@times, dataPred, postDist.mixProb(k,:));
    end
    pred.continuous = dataNew;
  end

  % predict discrete
  if Dd > 0
    pred.discrete = [];
    M = params.nClass;
    prob = zeros(sum(params.nClass),N);
    for k = 1:K
      prob = prob + bsxfun(@times, params.prob(:,k), postDist.mixProb(k,:));
    end
    pred.discrete = prob;
    %{
    idx = [];
    for d = 1:length(params.nClass)
      idx = [idx sum(M(1:d-1))+1:sum(M(1:d))];
      pred.discrete(idx,:) = prob(idx,:);
    end
    pred.discrete = prob(idx,:);
    %}
  end

function y = predictGauss(y, mean_, covMat) 

  m = find(isnan(y));
  o = find(~isnan(y));
  y(m) = mean_(m) + covMat(m,o)*inv(covMat(o,o))*(y(o) - mean_(o));

