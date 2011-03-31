  clear all
  setSeed(5)
  % parameters
  N = 500;
  mean_ = [5 -5; -5 5; -5 -5; 5 5]';
  covMat(:,:,1) = eye(size(mean_,1));
  covMat(:,:,2) = eye(size(mean_,1));
  covMat(:,:,3) = eye(size(mean_,1));
  L = randn(size(mean_,1));
  covMat(:,:,4) = L*L';
  mixProb =[0.3 0.3 0.2 0.2]';
  % generate latent state
  for n = 1:N
    q(:,n) = mnrnd(1,mixProb')';
    k = find(q(:,n));
    data(:,n) = mean_(:,k) + chol(covMat(:,:,k))*randn(length(mean_(:,k)),1);
  end
  % introduce missing data
  dataTruth = data;
  [D,N] = size(data);
  miss = rand(D,N)<0.001;
  data(miss) = NaN;
  idx = find(sum(miss)~=D); % remove the columns where all are missing
  data1.continuous = data(:,idx);
  data = data1;

  % learn params
  numOfMix = [4];
  runAlgo = 1;
  if runAlgo == 1
    % initialize
    setSeed(2)
    opt=struct('initMethod','random','numOfMix',numOfMix,'scale',3);
    [params0, data] = initGmm(data, [], opt);
    options = struct('maxNumOfItersLearn', 100, 'lowerBoundTol', 1e-2, 'regCovMat', 1);
    funcName = struct('inferFunc', @inferGmm, 'maxParamsFunc', @maxParamsGmm);
    [params logLik] = learnEm(data, funcName, params0, options);
  end

  y = data.continuous;
  plot(y(1,:),y(2,:),'rx');
  hold on
  plot(params.mean(1,:),params.mean(2,:),'bo','linewidth',2);
  for k = 1:numOfMix
    MyEllipse(params.covMat(:,:,k), params.mean(:,k), 'style', 'g-','intensity',0,'facefill',0);
  end

