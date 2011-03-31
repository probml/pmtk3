function [ss, logLik, postDist] = inferFA_miss(data, params, options)
% [SS, LOGLIK, POSTDIST] = inferFA_miss(DATA, PARAMS, OPTIONS) is same as
%   inferFA but handles missing values. See 'help inferFA' for details.
%
% See testLearnFA_miss.m for an example.
% See also : inferFA, maxParamsFA, initFA, inferMixedDataFA
% 
% Written by Emtiyaz, CS, UBC,
% modified on June 07, 2010

  [computeSs, computeLogLik, estimateBeta] = myProcessOptions(options, 'computeSs', 1, 'computeLogLik', 1, 'estimateBeta', 1);

  [D,N] = size(data.continuous);
  Dz = size(params.mean,1);
  y = data.continuous;
  multiplyMatrixWithVec = @(V,i) V*i;

  % missing data?
  idxObs = isnan(data.continuous);
  miss = find(sum(idxObs));
  obs = find(sum(idxObs)==0);

  % compute posterior covMat
  covMatPost = zeros(Dz,Dz,N);
  precMatPost = zeros(Dz,Dz,N);
  if ~isempty(obs)
    BpsiB = params.beta'*params.noisePrecMat*params.beta;
    precMatPost_obs = BpsiB + params.precMat;
    covMatPost_obs = inv(precMatPost_obs);
    covMatPost(:,:,obs) = bsxfun(@plus, covMatPost(:,:,obs), covMatPost_obs);
    precMatPost(:,:,obs) = bsxfun(@plus, precMatPost(:,:,obs), precMatPost_obs);
  end
  if ~isempty(miss)
    yc = mat2cell(data.continuous(:,miss),D,ones(1,length(miss))); 
    [covMatPost_miss, precMatPost_miss] = cellfun(@(yc)computeCovMatPost_cont(yc, params), yc, 'uniformOutput',0);
    covMatPost(:,:,miss) = reshape(cell2mat(covMatPost_miss), [Dz Dz length(miss)]);
    precMatPost(:,:,miss) = reshape(cell2mat(precMatPost_miss), [Dz Dz length(miss)]);
  end

  % compute posterior mean
  informLatent = params.precMat*params.mean;
  yc = data.continuous;
  yc(isnan(yc)) = 0;
  informLik = params.beta'*bsxfun(@rdivide, yc, diag(params.noiseCovMat));
  inform = bsxfun(@plus, informLik, informLatent);
  if ~isempty(obs)
    meanPost(:,obs) = covMatPost_obs*inform(:,obs);
  end
  if ~isempty(miss)
    informCell = mat2cell(inform(:,miss),Dz,ones(1,length(miss))); 
    meanPost(:,miss) = cell2mat(cellfun(multiplyMatrixWithVec, covMatPost_miss, informCell, 'uniformoutput',0));
  end

  % postDist
  if nargout > 2
    postDist.mean = meanPost;
    postDist.precMat = precMatPost;
    postDist.covMat = covMatPost;
  end

  missY = isnan(y);
  y0 = y;
  y0(missY) = 0;
  % sufficient statistics
  if computeSs
    ss.sumMean = sum(meanPost,2); 
    if options.estimateCovMat | options.estimateBeta
      ss.sumCovMat = sum(covMatPost,3) + meanPost*meanPost';
    end
    if options.estimateBeta
      % loading factors
      ss.sumLhs = y0*meanPost';
      if ~isempty(miss)
        for d = 1:D
          % if more mising than observed
          if length(miss) > length(obs)
            % then compute sum over all observed
            obs_d = find(~missY(d,:));
            A = meanPost(:,obs_d)*meanPost(:,obs_d)' + sum(covMatPost(:,:,obs_d),3);
            ss.beta(d,:) = ss.sumLhs(d,:)*inv(A + params.lambda*eye(Dz));
          else
            % else subtract the missing ones
            miss_d = find(missY(d,:));
            A = ss.sumCovMat - meanPost(:,miss_d)*meanPost(:,miss_d)' - sum(covMatPost(:,:,miss_d),3);
            ss.beta(d,:) = ss.sumLhs(d,:)*inv(A + params.lambda*eye(Dz));
          end
        end
      end
    else
      % noise covariance
      P = zeros(D,N);
      if ~isempty(obs)
        P(:,obs) = bsxfun(@plus, diag(params.beta*covMatPost_obs*params.beta'), P(:,obs));
      end
      if ~isempty(miss)
        P(:,miss) = cell2mat(cellfun(@(V)computeDiagBVB(V, params.beta), covMatPost_miss, 'uniformoutput',0));
      end
      ss.sumPhi = sum(((~missY.*(y0 - params.beta*meanPost)).^2 + ~missY.*P), 2);
    end
  else
    ss = 0;
  end

  % log Lik
  logLik = 0;
  if options.computeLogLik == 1
    % compute diag(BVB') if it doesn't exist already
    if ~exist('P','var')
      P = zeros(D,N);
      if ~isempty(obs)
        P(:,obs) = bsxfun(@plus, diag(params.beta*covMatPost_obs*params.beta'), P(:,obs));
      end
      if ~isempty(miss)
        P(:,miss) = cell2mat(cellfun(@(V)computeDiagBVB(V, params.beta), covMatPost_miss, 'uniformoutput',0));
      end
    end
    % measurement link likelihood
    logLink = sum(logMvnPdfWithMissingData(y, obs, params.beta*meanPost, params.noisePrecMat))...
      -0.5*sum(sum(bsxfun(@times, diag(params.noisePrecMat), ~missY.*P)));% trace(Psi^{-1}*B*V*B')

    % latent variable log prob
    t = 0; e = 0;
    if ~isempty(obs)
      t = t - 0.5*length(obs)*trace(params.precMat*covMatPost_obs);
      e = e + 0.5*length(obs)*logdet(covMatPost_obs);
    end
    if ~isempty(miss)
      t = t - 0.5*sum(cellfun(@(V)computeTrace(params.precMat, V), covMatPost_miss));
      e = e + 0.5*sum((cellfun(@(V)logdet(V), covMatPost_miss)));
    end
    logLatent = sum(logMvnPdfWithMissingData(params.mean, [1:N], meanPost, params.precMat)) + t;

    % prior on parameters
    logPrior = - 0.5*params.lambda*trace(params.noisePrecMat*params.beta*params.beta')...
      - (params.a + 1)*sum(log(diag(params.noiseCovMat)))...
      - params.b*sum(diag(params.noisePrecMat));

    % entropy
    entrpy = 0.5*N*log(2*pi)*Dz + e;
    logLik = logLink + logLatent + entrpy + logPrior;

    % add regularization term
    if options.estimateCovMat 
      if options.regCovMat
        logLik = logLik + 0.5*(params.nu0+Dz+1)*logdet(params.precMat) - 0.5*trace(params.S0*params.precMat);
      end
    end
    logLik = logLik/N;
  end

function [covMatPost, precMatPost] = computeCovMatPost_cont(yc, params)

  % find observed dimensions
  Dc = size(yc,1);

  obsC = find(~isnan(yc));
  BpsiB = params.beta(obsC,:)'*params.noisePrecMat(obsC,obsC)*params.beta(obsC,:);

  precMatPost = BpsiB + params.precMat;
  covMatPost = inv(precMatPost);

function P = computeDiagBVB(V, B) 

  P = diag(B*V*B');

function t = computeTrace(A,B) 
  t = trace(A*B);

