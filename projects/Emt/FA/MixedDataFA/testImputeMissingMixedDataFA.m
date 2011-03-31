  clear all
  setSeed(16)
  name = 'sim';
  switch name
  case 'sim'
    % make data
    N = 100;
    Dz = 4;
    Dc = 10;
    nClass = [2 2 2 2];
    mean_ = [5 5 -5 -5]';
    L = eye(Dz);
    covMat = L*L';
    z = repmat(mean_,1,N) + chol(covMat)*randn(Dz,N);
    noiseCovMat = 0.01*eye(Dc);%abs(diag(randn(Dc,1)));
    Bc = rand(Dc,Dz);
    % continuous data
    data.continuous = Bc*z + chol(noiseCovMat)*randn(Dc,N);
    [D,N] = size(data.continuous);
    miss = rand(D,N)<0.00;
    data.continuousTruth = data.continuous;
    data.continuous(miss) = NaN;
    % categorical data
    Bm = [];
    for c = 1:length(nClass)
      Bmc = rand(nClass(c)-1,Dz);
      p = [exp(Bmc*z); ones(1,N)];
      pMult = p./repmat(sum(p,1),nClass(c),1);
      data.categorical(c,:) = sum(repmat([1:nClass(c)],N,1).*mnrnd(1,pMult'),2);
      Bm = [Bm; Bmc];
    end
    % one of M encoding
    [D,N] = size(data.categorical);
    miss = rand(D,N)<0.1;
    data.categoricalTruth = data.categorical;
    data.categorical(miss) = NaN;
    data.categorical = encodeDataOneOfM(data.categorical, nClass);
    data.categoricalTruth = encodeDataOneOfM(data.categoricalTruth, nClass);
    data.binary = [];

    data_miss = data;
  case 'proto'
    N = 50;
    proto = [1 1 2; 2 2 1; 2 3 3; 1 3 4]';
    D = size(proto,1); 
    nClass = [2 3 4];
    % generate data
    y = [];
    for i = 1:size(proto,2)
      y = [y repmat(proto(:,i), 1, N)];
    end
    missing = rand(size(y))<0.01;
    y(missing) = NaN;
    data.categorical = y;
    data.categorical=encodeDataOneOfM(data.categorical, nClass);
    data.continuous = [];
    data.binary = [];

    % missing variables
    data_miss.categorical = [1 NaN 2; NaN 2 1; 2 NaN 3; 1 3 NaN; NaN NaN 3; 2 NaN 1]';
    data_miss.categorical = encodeDataOneOfM(data_miss.categorical, nClass);
    data_miss.continuous = [];
    data_miss.binary = [];

  end

  Dz = 8;
  % learn parameters
  opt=struct('Dz', Dz, 'nClass', nClass, 'initMethod', 'random');
  [params0, trainData] = initMixedDataFA(data, [], opt);
  params0.a = 1;
  params0.b = 1;
  options = struct('maxNumOfItersLearn',100, 'maxItersInfer', 3, 'lowerBoundTol', 1e-4, 'estimateBeta',1,'regCovMat',0, 'estimateCovMat',0);
  funcName = struct('inferFunc', @inferMixedDataFA_miss, 'maxParamsFunc', @maxParamsMixedDataFA);
  [params, logLik] = learnEm(trainData, funcName, params0, options);
  % impute missing variables
  [pred, logLik] = imputeMissingMixedDataFA_ver1(@inferMixedDataFA_miss, data_miss, params, struct('estimateCovMat',0,'estimateBeta',1));

