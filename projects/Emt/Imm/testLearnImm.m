  clear all
  setSeed(1)
  % generate data
  [trainData, testData, simParams] = makeSimDataImm(100);
  nClass = simParams.nClass;
  % encode train data
  trainData.discrete = encodeDataOneOfM(trainData.discrete, nClass,'M');
  % set missing discrete values to 0
  miss = isnan(trainData.discrete);
  trainData.discrete(miss) = 0;
  % learn params
  numOfMix = 2;
  runAlgo = 1;
  if runAlgo == 1
    setSeed(100)
    opt=struct('initMethod','random','numOfMix',numOfMix,'scale',3, 'refine', 0, 'nClass', nClass);
    [params0, trainData] = initImm(trainData, [], opt);
    options = struct('maxNumOfItersLearn', 40, 'lowerBoundTol', 1e-4, 'regCovMat', 1,'covMat', 'full');
    funcName = struct('inferFunc', @inferImm, 'maxParamsFunc', @maxParamsImm);
    [params, logLik] = learnEm(trainData, funcName, params0, options);
  end

  % encode test data
  testData.discrete = encodeDataOneOfM(testData.discrete, nClass,'M');
  % impute missing 
  pred = imputeMissingImm(testData, params, options);
  
