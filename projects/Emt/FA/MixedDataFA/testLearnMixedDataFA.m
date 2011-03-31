  % Test/Example file for EM for factor analysis
  clear all
  setSeed(1)
  % generate data
  [trainData,testData,simParams] = makeSimDataMixedDataFA(2000);
  nClass = simParams.nClass;

  % one of M encoding
  trainData.categorical = encodeDataOneOfM(trainData.discrete, nClass);
  testData.categorical = encodeDataOneOfM(testData.discrete, nClass);

  vals = [1:1:5];
  for i = 1:length(vals)
    Dz = 2;
    runAlgo = 1;
    if runAlgo == 1
      % initialize
      opt=struct('Dz', Dz, 'nClass', nClass, 'initMethod', 'random');
      [params0, trainData] = initMixedDataFA(trainData, [], opt);
      % prior for noise variance
      params0.a = -1;
      params0.b = 0;
      %params0.beta = [simParams.betaCont; simParams.betaMult];
      %params0.betaCont = simParams.betaCont;
      %params0.betaMult = simParams.betaMult;
      options = struct('maxNumOfItersLearn', 1000, 'maxItersInfer', 3, 'lowerBoundTol', 1e-4, 'estimateBeta', 1, 'estimateCovMat',0,'estimateMean',1);
      funcName = struct('inferFunc', @inferMixedDataFA, 'maxParamsFunc', @maxParamsMixedDataFA);
      [params, logLik] = learnEm(trainData, funcName, params0, options);
    end
    trainLogLikFA(i) = logLik(end);
    params.psi = randn(size(testData.categorical));
    [ss, testLogLikFA(i), postDist] = inferMixedDataFA(testData, params, options);
  end

  %[mseC, mseD, entrpyD] = imputeMissing(testData, 'randomMixed', 'disGaussFA', params, options)
