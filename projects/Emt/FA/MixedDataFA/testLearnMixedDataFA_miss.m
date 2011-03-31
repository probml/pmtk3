  clear all
  setSeed(16)
  % generate data
  [trainData,testData,simParams] = makeSimDataMixedDataFA(100);
  nClass = simParams.nClass;
  % introduce missing variables in train data 
  missProb = 0.1;
  trainData.continuousTruth = trainData.continuous;
  trainData.discreteTruth = trainData.discrete;
  [D,N] = size(trainData.continuous);
  miss = rand(D,N)<missProb;
  trainData.continuous(miss) = NaN;
  [D,N] = size(trainData.discrete);
  miss = rand(D,N)<missProb;
  trainData.discrete(miss) = NaN;

  % one of M encoding
  trainData.categorical = encodeDataOneOfM(trainData.discrete, nClass);

  Dz = 2;
  runAlgo = 1;
  if runAlgo == 1
    % initialize
    opt=struct('Dz', Dz, 'nClass', nClass, 'initMethod', 'random');
    [params0, trainData] = initMixedDataFA(trainData, [], opt);
    % prior for noise variance
    params0.a = 1;
    params0.b = 1;
    options = struct('maxNumOfItersLearn',100, 'maxItersInfer', 3, 'lowerBoundTol', 1e-4, 'estimateBeta',1,'regCovMat',0, 'estimateCovMat',0);
    funcName = struct('inferFunc', @inferMixedDataFA_miss, 'maxParamsFunc', @maxParamsMixedDataFA);
    [params, logLik] = learnEm(trainData, funcName, params0, options);
  end


