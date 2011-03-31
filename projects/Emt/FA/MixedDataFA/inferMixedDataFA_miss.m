function [ss, logLik, postDist] = inferMixedDataFA_miss(data, params, options)
% [SS, LOGLIK, POSTDIST] = inferMixedDataFA_miss(DATA, PARAMS, OPTIONS) is same as
%   inferMixedDataFA but handles missing values. See 'help inferMixedDataFA' for details.
%
% See testLearnMixedDataFA_miss.m for an example.
% See also : maxParamsMixedDataFA, initMixedDataFA, inferMixedDataFA,
% inferMixedDataFA_jaakkola 
% 
% Written by Emtiyaz, CS, UBC,
% modified on June 09, 2010

  %[computeSs, computeLogLik, estimateBeta] = myProcessOptions(options, 'computeSs', 1, 'computeLogLik', 1, 'estimateBeta', 1);
  [computeSs, computeLogLik, estimateBeta, maxItersInfer, fixDiag] = myProcessOptions(options, 'computeSs', 1, 'computeLogLik', 1, 'estimateBeta', 1, 'maxItersInfer', 5, 'fixDiag', 0);

  %maxItersInfer = options.maxItersInfer;
  [Dc,Nc] = size(data.continuous);
  [Db,Nb] = size(data.binary);
  [Dm,Nm] = size(data.categorical);
  N = max([Nb Nc Nm]);
  Dz = size(params.mean,1);
  multiplyMatrixWithVec = @(V,i) V*i;

  % missing data?
  idxObs = isnan([data.continuous; data.categorical]);
  miss = find(sum(idxObs));
  obs = find(sum(idxObs)==0);

  % multinomial variational parameters
  if Dm~=0 
    M = params.nClass-1;
    psi = params.psi;
  else
    M = [];
    psi = [];
  end
  D = Dc + sum(M);

  % POSTERIOR COVMAT
  covMatPost = zeros(Dz,Dz,N);
  precMatPost = zeros(Dz,Dz,N);
  % for observed variables
  if ~isempty(obs)
    BpsiB = 0;
    if Dc ~= 0
      BpsiB = BpsiB + params.betaCont'*params.noisePrecMat*params.betaCont;
    end
    if Dm ~= 0
      for d = 1:length(M)
        idx = sum(M(1:d-1))+1:sum(M(1:d));
        BpsiB = BpsiB + params.betaMult(idx,:)'*params.A{d}*params.betaMult(idx,:);
      end
    end
    precMatPost_obs = BpsiB + params.precMat;
    covMatPost_obs = inv(precMatPost_obs);
    covMatPost(:,:,obs) = bsxfun(@plus, covMatPost(:,:,obs), covMatPost_obs);
    precMatPost(:,:,obs) = bsxfun(@plus, precMatPost(:,:,obs), precMatPost_obs);
  end
  % for missing variables
  if ~isempty(miss)
    if Dc>0 & Dm == 0
      yc = mat2cell(data.continuous(:,miss),Dc,ones(1,length(miss))); 
      [covMatPost_miss, precMatPost_miss] = cellfun(@(yc)computeCovMatPost_cont(yc, params), yc, 'uniformOutput',0);
    elseif Dm>0 & Dc == 0
      ym = mat2cell(data.categorical(:,miss),Dm,ones(1,length(miss)));
      [covMatPost_miss, precMatPost_miss] = cellfun(@(ym)computeCovMatPost_mult(ym, params), ym, 'uniformOutput',0);
    elseif Dm>0 & Dc >0
      yc = mat2cell(data.continuous(:,miss),Dc,ones(1,length(miss))); 
      ym = mat2cell(data.categorical(:,miss),Dm,ones(1,length(miss)));
      [covMatPost_miss, precMatPost_miss] = cellfun(@(yc,ym)computeCovMatPost(yc, ym, params), yc, ym, 'uniformOutput',0);
    else
      error('all data empty?');
    end
    covMatPost(:,:,miss) = reshape(cell2mat(covMatPost_miss), [Dz Dz length(miss)]);
    precMatPost(:,:,miss) = reshape(cell2mat(precMatPost_miss), [Dz Dz length(miss)]);
  end

  % precompute some quantities
  informLatent = params.precMat*params.mean;
  y = zeros(Dc + sum(M),N);
  noisePrecMat = zeros(Dc + sum(M));

  %POSTERIOR MEAN
  informLik = 0;
  logMult = 0;
  logMult_n = 0;
  if Dc~=0 
    % continuous measurements
    yc = data.continuous;
    yc(isnan(yc)) = 0;
    informLik = informLik + params.betaCont'*bsxfun(@rdivide, yc, diag(params.noiseCovMat));
    y(1:Dc,:) = data.continuous;
    noisePrecMat(1:Dc,1:Dc) = params.noisePrecMat;
  end
  % multinomial measurements
  if Dm ~= 0;
    % optimize variational params
    for iter = 1:maxItersInfer
      b = [];
      for d = 1:length(M)
        idx = sum(M(1:d-1))+1:sum(M(1:d));
        psi_d = psi(idx,:);
        smPsi = exp(myLogSoftMax([psi_d; zeros(1,N)]));
        Apsi = params.A{d}*psi_d;
        b = [b; Apsi - smPsi(1:end-1,:)];
      end
      % if missing variable set to 0 and compute information
      ym = (data.categorical + b);
      ym(isnan(ym)) = 0;
      informLikMult = params.betaMult'*ym; 
      inform = bsxfun(@plus, informLik + informLikMult, informLatent);
      % compute mean Post
      if ~isempty(obs)
        meanPost(:,obs) = covMatPost_obs*inform(:,obs);
      end
      if ~isempty(miss)
        informCell = mat2cell(inform(:,miss),Dz,ones(1,length(miss))); 
        meanPost(:,miss) = cell2mat(cellfun(multiplyMatrixWithVec, covMatPost_miss, informCell, 'uniformoutput',0));
      end
      % new variational parameters
      psiOld = psi;
      psi = params.betaMult*meanPost;
      % convergence
      [converged, incr] = isConverged([psiOld(:)  psiOld(:)  psi(:)], 1e-2, 'parameter');
      if converged; break; end;
    end
    % update information vector
    informLik = informLik + informLikMult; 

    % compute pseudo measurements and contribution to logLik
    for d = 1:length(M)
      idx = sum(M(1:d-1))+1:sum(M(1:d));
      psi_d = psi(idx,:);
      smPsi = exp(myLogSoftMax([psi_d; zeros(1,N)]));
      Apsi = params.A{d}*psi_d;
      smPsi = smPsi(1:end-1,:);
      b = Apsi - smPsi;
      y_m = params.invA{d}*(data.categorical(idx,:) + b);
      y(Dc+idx(1):Dc+idx(end),:) = y_m;
      noisePrecMat(Dc+idx(1):Dc+idx(end),Dc+idx(1):Dc+idx(end)) = params.A{d};
      c = 0.5*sum(psi_d.*Apsi,1) - sum(smPsi.*psi_d,1) + logsumexp([psi_d; zeros(1,N)]);

      obs_d_1 = ~sum(isnan(y_m),1);
      %obs_d = find(~sum(isnan(y_m),1));
      y_m(isnan(y_m)) = 0;% for lower bound, 0 the missing variables
      %logMult = logMult + 0.5*length(obs_d)*log(2*pi)*length(idx)...
      %          + 0.5*length(obs_d)*logdet(params.invA{d})...
      %          + 0.5*sum(sum(y_m(:,obs_d).*(params.A{d}*y_m(:,obs_d)))) - sum(c(obs_d)); 
      logMult_n = logMult_n + 0.5*obs_d_1*log(2*pi)*length(idx)...
                + 0.5*logdet(params.invA{d})*obs_d_1...
                + 0.5*sum(y_m.*(params.A{d}*y_m),1) - obs_d_1.*c; 
    end
  end
  logMult = sum(logMult_n);

  % compute mean
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
    postDist.psi = psi;
    postDist.y = y;
    postDist.noisePrecMat = noisePrecMat;
    postDist.noiseCovMat = inv(noisePrecMat);
    postDist.logMult = logMult_n;
  end

  missY = isnan(y);
  y0 = y;
  y0(missY) = 0;
  % sufficient statistics
  if computeSs
    ss.psi = psi;
    ss.sumMean = sum(meanPost,2); 
    ss.noisePrecMat = noisePrecMat;
    ss.sumCovMat = sum(covMatPost,3) + meanPost*meanPost';
    if estimateBeta
      ss.sumLhs = y0*meanPost';
      if ~isempty(miss)
        for d = 1:D
          % if more mising than observed
          if length(miss) > length(obs)
            % then compute sum over all observed
            obs_d = find(~missY(d,:));
            A = meanPost(:,obs_d)*meanPost(:,obs_d)' + sum(covMatPost(:,:,obs_d),3);
            ss.beta(d,:) = ss.sumLhs(d,:)*inv(A);
          else
            % else subtract the missing ones
            miss_d = find(missY(d,:));
            A = ss.sumCovMat - meanPost(:,miss_d)*meanPost(:,miss_d)' - sum(covMatPost(:,:,miss_d),3);
            ss.beta(d,:) = ss.sumLhs(d,:)*inv(A);
          end
        end
      end
    else
      % Phi
      if Dc>0
        P = zeros(Dc,N);
        if ~isempty(obs)
          P(:,obs) = bsxfun(@plus, diag(params.betaCont*covMatPost_obs*params.betaCont'), P(:,obs));
        end
        if ~isempty(miss)
          P(:,miss) = cell2mat(cellfun(@(V)computeDiagBVB(V, params.betaCont), covMatPost_miss, 'uniformoutput',0));
        end
        ss.sumPhi = sum(((~missY(1:Dc,:).*(y0(1:Dc,:) - params.betaCont*meanPost)).^2 + ~missY(1:Dc,:).*P(1:Dc,:)), 2);
      end
    end
  else
    ss = 0;
  end

  % log Lik
  logLik = 0;
  if computeLogLik == 1
    % compute diag(BVB')
    psiBVB = 0;
    psiB = noisePrecMat*params.beta;
    if ~isempty(obs)
      psiBVB = psiBVB - 0.5*length(obs)*trace(noisePrecMat*params.beta*covMatPost_obs*params.beta');
    end
    if ~isempty(miss)
      psiBVB_miss = cell2mat(cellfun(@(V)computeTrace3(psiB,V,params.beta'), covMatPost_miss, 'uniformoutput',0));
    end
    % measurement link likelihood
    logLink = sum(logMvnPdfWithMissingData(y, obs, params.beta*meanPost, noisePrecMat)) + psiBVB;% trace(Psi^{-1}*B*V*B')

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
    % entropy
    entrpy = 0.5*N*log(2*pi)*Dz + e;
    % prior on parameters
    logPrior = 0;
    if Dc >0
    logPrior = - (params.a + 1)*sum(log(diag(params.noiseCovMat)))...
      - params.b*sum(diag(params.noisePrecMat));
    end
    switch params.priorCovMat
    case 'invWishart'
      logPrior = logPrior + 0.5*(params.nu0+Dz+1)*logdet(params.precMat) - 0.5*trace(params.S0*params.precMat);
    case 'laplace'
      %logPrior = logPrior - 0.5*N*params.lambdaLaplace*sum(sum(abs(setdiag(params.precMat,0))));
      lambda  = params.lambdaLaplace;
      if fixDiag
        logPrior = logPrior - lambda*sum(sum(abs(setdiag(params.precMat,0))));
      else
        logPrior = logPrior - lambda*sum(sum(abs(params.precMat)));
      end
    otherwise
      error('No such prior for covMat');
    end

    % log likelihood
    logLik = logLink + logLatent + entrpy + logMult + logPrior;
    logLik = logLik/N;
  end

function [meanPost] = computeMeanPost(inform, covMatPost)

  meanPost = covMatPost*inform;

function [covMatPost, precMatPost] = computeCovMatPost(yc, ym, params)

  % find observed dimensions
  Dc = size(yc,1);
  Dm =length(params.nClass); 
  M = params.nClass-1;

  BpsiB = 0;
  obsC = find(~isnan(yc));
  BpsiB = BpsiB + params.betaCont(obsC,:)'*params.noisePrecMat(obsC,obsC)*params.betaCont(obsC,:);

  for d = 1:Dm
    idx = sum(M(1:d-1))+1:sum(M(1:d));
    if sum(~isnan(ym(idx)))
      BpsiB = BpsiB + params.betaMult(idx,:)'*params.A{d}*params.betaMult(idx,:);
    end
  end
  precMatPost = BpsiB + params.precMat;
  covMatPost = inv(precMatPost);

function [covMatPost, precMatPost] = computeCovMatPost_mult(ym, params)

  % find observed dimensions
  Dm =length(params.nClass); 
  M = params.nClass-1;

  BpsiB = 0;
  for d = 1:Dm
    idx = sum(M(1:d-1))+1:sum(M(1:d));
    if sum(~isnan(ym(idx)))
      BpsiB = BpsiB + params.betaMult(idx,:)'*params.A{d}*params.betaMult(idx,:);
    end
  end
  precMatPost = BpsiB + params.precMat;
  covMatPost = inv(precMatPost);

function [covMatPost, precMatPost] = computeCovMatPost_cont(yc, params)

  % find observed dimensions
  Dc = size(yc,1);

  obsC = find(~isnan(yc));
  BpsiB = params.betaCont(obsC,:)'*params.noisePrecMat(obsC,obsC)*params.betaCont(obsC,:);

  precMatPost = BpsiB + params.precMat;
  covMatPost = inv(precMatPost);

function P = computeDiagBVB(V, B) 

  P = diag(B*V*B');

function t = computeTrace3(A,B,C) 
  t = trace(A*B*C);

function t = computeTrace(A,B) 
  t = trace(A*B);



