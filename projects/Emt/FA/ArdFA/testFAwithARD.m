  clear all
  setSeed(1)
  % make data
  D = 10;
  Dz = 4;
  N = 20;
  mean_ = zeros(Dz,1);
  %L = randn(Dz,Dz);
  L = eye(Dz);
  covMat = L*L';
  z = repmat(mean_,1,N) + chol(covMat)*randn(Dz,N);
  noiseCovMat = abs(diag(randn(D,1)));
  B = randn(D,Dz);
  data.continuous = B*z + chol(noiseCovMat)*randn(D,N);

  runAlgo = 1;
  if runAlgo == 1
    % initialize
    opt=struct('Dz', Dz);
    [params0, data] = initFA(data, [], opt);
    options = struct('maxNumOfItersLearn', 100, 'lowerBoundTol', 1e-4, 'estimateBeta',0,'regCovMat',0,'estimateCovMat',0);
    options.computeSs = 1;
    options.computeLogLik = 1;

    params0.mean = zeros(Dz,1);
    params0.covMat = eye(Dz);
    params0.beta = B;
    params0.noiseCovMat = noiseCovMat;
    params0.noisePrecMat = inv(noiseCovMat);
    % prior for noise variance
    params0.a = 1;
    params0.b = 1;
    % prior for beta
    params0.lambda = .1;
    [ss, logLik, postDist] = inferFA(data, params0, options);
    % dual variable and hyperparamter
    params0.lambdaG = 0;
    params0.theta = 0;
    params0.u = ones(Dz,1);

    precMatPost = params0.beta'*params0.noisePrecMat*params0.beta + eye(Dz);
    covMatPost = inv(precMatPost);
    invC = params0.noisePrecMat + params0.noisePrecMat*params0.beta*covMatPost*params0.beta'*params0.noisePrecMat;
    params0.u = N*diag(params0.beta'*invC*params0.beta) + (2 -params0.lambdaG);
    params0.z = zeros(Dz,N);
    for i = 1:1
      [ss1, logLik1, postDist1] = inferFAwithArd(data, params0, options);
      params0.u = ss1.u;
      params0.z = ss1.z;
    end
    %funcName = struct('inferFunc', @inferFA, 'maxParamsFunc', @maxParamsFA);
    %[params, logLik] = learnEm(data, funcName, params0, options);
  end
    

