  clear all
  setSeed(1)
  runAlgo = 1;
  % generate data
  [trainData,testData,simParams] = makeSimDataMixedDataFA(500);
  nClass = simParams.nClass;
  % one of M encoding
  trainData.categorical = encodeDataOneOfM(trainData.discrete, nClass);
  trainData.binary = [];

  Dz = 2;
  if runAlgo == 1
    % initialize
    opt=struct('Dz', Dz, 'initMethod', 'random', 'nClass', nClass);
    [params0, trainData] = initMixedDataFA(trainData, [], opt);
    params0.a = 1;
    params0.b = 1;
    %params0.noiseCovMat = simParams.noiseCovMat;
    %params0.betaMult = simParams.betaMult;
    %params0.betaCont = simParams.betaCont;
    %params0.beta = [simParams.betaCont; simParams.betaMult];
    options = struct('maxNumOfItersLearn',100, 'maxItersInfer', 3, 'lowerBoundTol', 1e-4, 'estimateBeta',1,'regCovMat',0, 'estimateCovMat',0,'display',1,'checkConvergenceMethod','parameter');
    funcName = struct('inferFunc', @inferMixedDataFA_laplace, 'maxParamsFunc', @maxParamsMixedDataFA);
    [params, logLik] = learnEm(trainData, funcName, params0, options);
  end

  break
  [pred, logLik] = imputeMissingMixedDataFA_ver1(@inferMixedDataFA_miss, trainData, params, options);
  yhat = pred.categorical';
  mean((yhat(missing) - X(missing)).^2)
  break

  % impute missing values in training set
  [pred, logLik] = imputeMissingMixedDataFA_ver1(@inferMixedDataFA_miss, trainData, params, options);
  yhat = pred.continuous;
  y = trainData.continuousTruth;
  err_cont = mean((y(:)-yhat(:)).^2)

  yhat = pred.categorical(1,:);
  y = trainData.categoricalTruth(1,:);
  err_bin = mean((y(:)-yhat(:)).^2)
  break

  % impute missing values in test set
  [pred, logLik] = imputeMissingMixedDataFA_ver1(@inferMixedDataFA_miss, testData, params, options);
  yhat = pred.continuous;
  y = testData.continuousTruth;
  err_cont = mean((y(:)-yhat(:)).^2)

  yhat = pred.categorical(1,:);
  y = testData.categoricalTruth(1,:);
  err_bin = mean((y(:)-yhat(:)).^2)

