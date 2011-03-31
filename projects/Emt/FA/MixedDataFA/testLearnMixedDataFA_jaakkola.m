  clear all
  setSeed(4)

  [trainData,testData,simParams] = makeSimDataMixedDataFA(100);
  %trainData.continuous = [];
  nClass = simParams.nClass;
  Dz = 2;
  opt=struct('Dz',Dz,'initMethod','random','nClass',nClass);
  options = struct('maxNumOfItersLearn',100,'maxItersInfer',3,'lowerBoundTol',1e-5,'estimateBeta',1,'estimateCovMat',0);

  trainData.discrete = encodeDataOneOfM(trainData.discrete, nClass);

  % jaakkola bound
  trainData.binary = trainData.discrete;
  trainData.categorical = [];
  setSeed(100)
  [params0, trainData] = initMixedDataFA(trainData, [], opt);
  params0.a = 1;
  params0.b = 1;
  funcName = struct('inferFunc', @inferMixedDataFA_jaakkola, 'maxParamsFunc', @maxParamsMixedDataFA);
  [params_j, logLik_j] = learnEm(trainData, funcName, params0, options);

  %{
  % bohning bound
  trainData.binary = [];
  trainData.categorical = trainData.discrete;
  setSeed(100)
  [params0, trainData] = initMixedDataFA(trainData, [], opt);
  params0.a = 1;
  params0.b = 1;
  [ss, logLik, postDist] = inferMixedDataFA(trainData, params0, []);
  funcName = struct('inferFunc', @inferMixedDataFA, 'maxParamsFunc', @maxParamsMixedDataFA);
  [params, logLik] = learnEm(trainData, funcName, params0, options);
  plot(logLik_j,'r');
  hold on
  plot(logLik,'b');
  %}


