  %clear all
  setSeed(1)
  [trainData, testData, simParams] = makeSimDataMixtureFA(100);

  Dz = 2;
  K = 2;
  runAlgo = 1;
  if runAlgo == 1
    % initialize
    opt=struct('Dz', Dz, 'K', K);
    [params0, trainData] = initMixtureFA(trainData, [], opt);
    % prior for noise variance
    params0.a = -1;
    params0.b = 0;
    % run EM
    options = struct('maxNumOfItersLearn', 2000, 'lowerBoundTol', 1e-20, 'estimateBeta',1,'regCovMat',0,'estimateCovMat',0);
    funcName = struct('inferFunc', @inferMixtureFA, 'maxParamsFunc', @maxParamsMixtureFA);
    [params, logLik] = learnEm(trainData, funcName, params0, options);
  end
    


