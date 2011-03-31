function [ss, logLik, postDist] = inferFAwithArd(data, params, options)

  % inference for FA
  [D,N] = size(data.continuous);
  Dz = size(params.mean,1);
  y = data.continuous;

  betaTimesNoisePrecMat = params.beta'*params.noisePrecMat;

  % regularization parameter for group lasso
  lambda = 2*sqrt(params.u + params.theta^2);
  % initialize z
  W_groupSparse = params.z;%zeros(Dz,N);
  % run group lasso
  %---------------
  funObj = @(W)SimultaneousSquaredError(W,params.beta,y);
  groups = repmat([1:Dz]',1,N);
  groups = groups(:);
  nGroups = max(groups);
  % Initialize auxiliary variables that will bound norm
  alpha = zeros(nGroups,1);
  penalizedFunObj = @(W)auxGroupLoss(W,groups,lambda,funObj);

  % Set up L_1,inf Projection Function
  [groupStart,groupPtr] = groupl1_makeGroupPointers(groups);
  funProj = @(W)auxGroupL2Project(W,Dz*N,groupStart,groupPtr);
  % Solve with PQN
  fprintf('\nComputing group-sparse simultaneous regression parameters...\n');
  Walpha = minConF_SPG(penalizedFunObj,[W_groupSparse(:);alpha],funProj, struct('verbose',1));
  % Extract parameters from augmented vector
  W_groupSparse(:) = Walpha(1:Dz*N);
  W_groupSparse(abs(W_groupSparse) < 1e-4) = 0;
  Z = W_groupSparse;
  %---------------

  % compute gamma
  gamma = sqrt(sum(Z.^2,2))./lambda;
  %idx = find(gamma>1e-10);
  %gamma = gamma(idx);

  % compute covMatPost
  precMatPost = params.beta'*params.noisePrecMat*params.beta + diag(1./max(gamma,1e-10));
  covMatPost = inv(precMatPost);
  % compute u
  invC = params.noisePrecMat + params.noisePrecMat*params.beta*covMatPost*params.beta'*params.noisePrecMat;
  u = N*diag(params.beta'*invC*params.beta) + (2 -params.lambdaG)./max(gamma,1e-10);
  % compute posterior mean
  meanPost = covMatPost*(bsxfun(@plus, betaTimesNoisePrecMat*y, params.precMat*params.mean));

  % postDist
  if nargout > 2
    postDist.mean = meanPost;
    postDist.precMat = precMatPost;
    postDist.covMat = covMatPost;
  end

  % sufficient statistics
  if options.computeSs
    ss.z = Z;%(idx,:);
    ss.u = u;
    ss.sumMean = sum(meanPost,2); 
    ss.sumCovMat = N*covMatPost + meanPost*meanPost';
    if options.estimateBeta
      ss.sumLhs = y*meanPost';
    else
      ss.sumPhi = sum((y - params.beta*meanPost).^2,2) + N*diag(params.beta*covMatPost*params.beta');
    end
  else
    ss = 0;
  end

  % log Lik
  logLik = 0;
  if options.computeLogLik == 1
    logLink = sum(logMvnPdfWithMissingData(y, [1:N], params.beta*meanPost, params.noisePrecMat))...
      - 0.5*N*trace(betaTimesNoisePrecMat'*covMatPost*params.beta');
    logLatent = sum(logMvnPdfWithMissingData(params.mean, [1:N], meanPost, params.precMat))...
      - 0.5*N*trace(params.precMat*covMatPost);
    entrpy = 0.5*N*(log(2*pi)*Dz + logdet(covMatPost));
    % prior on parameters
    logPrior = - 0.5*params.lambda*trace(params.noisePrecMat*params.beta*params.beta')...
      - (params.a + 1)*sum(log(diag(params.noiseCovMat)))...
      - params.b*sum(diag(params.noisePrecMat));

    logLik = logLink + logLatent + entrpy + logPrior;

    if options.regCovMat == 1
      logLik = logLik + 0.5*(params.nu0+Dz+1)*logdet(params.precMat) - 0.5*trace(params.S0*params.precMat);
    end
    logLik = logLik/N;
  end


