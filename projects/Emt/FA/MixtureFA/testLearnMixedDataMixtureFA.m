  clear all
  setSeed(14)
  [trainData, testData, simParams] = makeSimDataMixtureFA(30);
  trainData.binary = [];
  nClass = simParams.nClass;
  trainData.categorical = encodeDataOneOfM(trainData.discrete, nClass, 'M+1');

  Dz = 2;
  K = 2;
  runAlgo = 1;
  if runAlgo == 1
    % initialize
    opt=struct('Dz', Dz, 'K', K, 'nClass', nClass);
    [params0, trainData] = initMixedDataMixtureFA(trainData, [], opt);
    % prior for noise variance
    params0.a = 1;
    params0.b = 1;
    params0.alpha0 = 2;
    % prior for beta
    params0.beta = simParams.beta;
    params0.betaCont = simParams.betaCont;
    params0.betaMult = simParams.betaMult;

    options = struct('maxNumOfItersLearn', 100, 'lowerBoundTol', 1e-6, 'estimateBeta',1,'regCovMat',0,'estimateCovMat',0,'maxItersInfer',3);
    funcName = struct('inferFunc', @inferMixedDataMixtureFA, 'maxParamsFunc', @maxParamsMixedDataMixtureFA);
    [params, logLik] = learnEm(trainData, funcName, params0, options);
  end

  testData.categorical = encodeDataOneOfM(testData.discrete, nClass, 'M+1');
  testData.binary = [];
  [pred, logLik] = imputeMissingMixedDataMixtureFA(@inferMixedDataMixtureFA_miss, testData, params, []);
    
