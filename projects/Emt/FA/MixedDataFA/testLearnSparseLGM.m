  % Test/Example file for EM for sparse linera gaussian models
  clear all
  %setSeed(2)
  N = 1000;
  nClass = [2 2];
  Dc = 2;
  Dz = length(nClass) + Dc;
  mean_ = [zeros(Dz,1)];
  precMat = [1 0.5 0 0; 0.5 1 0 0; 0 0 1 0.5; 0 0 0.5 1];
  covMat = inv(precMat);

  % generate data
  z = mvnrnd(mean_(:)',covMat,N)';
  noiseCovMat = [.01 0; 0 .02];
  Bc = eye(Dc,Dz);
  yc = mvnrnd((Bc*z)', noiseCovMat, N)';
  Bm1{1} = 2;
  Bm1{2} = 2;
  Bm = [];
  yd = [];
  for d = 1:length(nClass)
    M = nClass(d)-1;
    Bmd = zeros(M,Dz);
    Bmd(:,Dc+d) = Bm1{d};
    p = [exp(Bmd*z); ones(1,N)];
    pMult = p./repmat(sum(p,1),nClass(d),1);
    t = mnrnd(1,pMult')';
    yd(d,:) = sum(repmat([1:nClass(d)]',1,N).*t,1);
    Bm = [Bm; Bmd];
  end
  trainData.continuous = yc;
  trainData.discrete = yd;
  trainData.categorical = encodeDataOneOfM(trainData.discrete, nClass);

  % SPARSE LGM
  runAlgo = 1;
  if runAlgo == 1
    % initialize
    opt=struct('nClass', nClass, 'initMethod', 'random');
    [params0, trainData] = initSparseLGM(trainData, [], opt);
    % reg params
    params0.lambdaLaplace = 10; 
    params0.a = 1;
    params0.b = 1;
    tic
    options = struct('maxNumOfItersLearn', 1000, 'maxItersInfer', 5, 'lowerBoundTol', 1e-5, 'estimateBeta', 1,'estimateCovMat', 1, 'estimateMean', 1, 'estimateNoiseCovMat', 1, 'fixDiag',0);
    funcName = struct('inferFunc', @inferMixedDataFA, 'maxParamsFunc', @maxParamsSparseLGM);
    [params, logLik] = learnEm(trainData, funcName, params0, options);
    % paramsT
    paramsT = params0;
    paramsT.beta = [Bc; Bm];
    paramsT.betaMult = Bm;
    paramsT.betaCont = Bc;
    paramsT.noiseCovMat = noiseCovMat;
    paramsT.noisePrecMat = inv(noiseCovMat);
    paramsT.precMat = precMat;
    paramsT.covMat = inv(precMat);
    paramsT.mean = mean_;
    [ss, logLikT, postDist] = inferMixedDataFA(trainData, paramsT, options);
    [logLikT logLik(end)]
  end

