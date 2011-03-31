  % Test/Example file for EM for factor analysis with missing values
  clear all
  setSeed(2)
  % generate data
  D = 10;
  Dz = 2;
  N = 100;
  mean_ = [5 -5]';
  L = eye(Dz,Dz);
  covMat = L*L';
  z = repmat(mean_,1,N) + chol(covMat)*randn(Dz,N);
  noiseCovMat = abs(diag(randn(D,1)));
  B = rand(D,Dz);
  data.continuous = B*z + chol(noiseCovMat)*randn(D,N);

  % introduce missing values
  [D,N] = size(data.continuous);
  miss = rand(D,N)<0.5;
  data.continuousTruth = data.continuous;
  data.continuous(miss) = NaN;

  runAlgo = 1;
  if runAlgo == 1
    % initialize
    opt=struct('Dz', Dz,'initMethod','PCA');
    [params0, data] = initFA(data, [], opt);
    % prior for noise variance
    params0.a = 1;
    params0.b = 1;
    % prior for beta
    params0.lambda = 0;
    % run EM
    options = struct('maxNumOfItersLearn', 100, 'lowerBoundTol', 1e-4, 'estimateBeta',1,'estimateCovMat',0);
    funcName = struct('inferFunc', @inferFA_miss, 'maxParamsFunc', @maxParamsFA);
    [params, logLik] = learnEm(data, funcName, params0, options);
  end
    

