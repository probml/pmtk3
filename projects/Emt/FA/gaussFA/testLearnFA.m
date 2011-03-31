  % Test/Example file for EM for factor analysis
  clear all
  setSeed(1)
  % generate data
  D = 10;
  Dz = 2;
  N = 1000;
  mean_ = [5 -5]';
  L = eye(Dz);
  covMat = L*L';
  z = repmat(mean_,1,N) + chol(covMat)*randn(Dz,N);
  noiseCovMat = abs(diag(randn(D,1)));
  B = randn(D,Dz);
  data.continuous = B*z + chol(noiseCovMat)*randn(D,N);

  runAlgo = 1;
  if runAlgo
    % initialize
    opt=struct('Dz', Dz);
    [params0, data] = initFA(data, [], opt);
    % prior for noise variance
    params0.a = 1;
    params0.b = 1;
    % prior for beta
    params0.lambda = .1;
    %params0.beta = B;
    options = struct('maxNumOfItersLearn', 100, 'lowerBoundTol', 1e-4, 'estimateBeta',1,'estimateCovMat',0);
    funcName = struct('inferFunc', @inferFA, 'maxParamsFunc', @maxParamsFA);
    [params, logLik] = learnEm(data, funcName, params0, options);
  end
    

