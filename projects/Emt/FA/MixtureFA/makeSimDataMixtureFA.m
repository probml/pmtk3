function [trainData, testData, params]=makeSimDataMixtureFA(N)

  Dz = 2;
  Dc = 2;
  nClass = [2 3 4];
  K = 2;
  missProb = 0.1;
  % likelihood parameters
  mean_ = [-5 -5; 5 5]';%; -5 5]';
  mixProb = [0.4 0.6]';
  for k = 1:K
    covMat(:,:,k) = eye(Dz,Dz);
    betaCont(:,:,k) = rand(Dc,Dz);
    betaMult(:,:,k) = rand(sum(nClass-1),Dz);
    beta(:,:,k) = [betaCont(:,:,k); betaMult(:,:,k)];
  end
  noiseCovMat = diag(2*rand(Dc,1));
  % generate latent state
  for n = 1:N
    q(:,n) = mnrnd(1,mixProb')';
    k = find(q(:,n));
    z(:,n) = mean_(:,k) + chol(squeeze(covMat(:,:,k)))*randn(Dz,1);
    yc(:,n) = betaCont(:,:,k)*z(:,n) + chol(noiseCovMat)*randn(Dc,1);
    for d = 1:length(nClass)
      M = nClass -1;
      idx = sum(M(1:d-1))+1:sum(M(1:d));
      p = [exp(betaMult(idx,:,k)*z(:,n)); 1];
      pMult = p./repmat(sum(p,1),nClass(d),1);
      yd(d,n) = sum([1:nClass(d)].*mnrnd(1,pMult'),2);
    end
  end
  % params
  params.mean = mean_;
  params.covMat = covMat;
  params.mixProb = mixProb;
  params.noiseCovMat = noiseCovMat;
  params.beta = beta;
  params.betaCont = betaCont;
  params.betaMult = betaMult;
  params.nClass = nClass;

  % split test and train data
  ratio = .7;
  [trainData, testData] = splitData(yc,yd,ratio);

  % introduce missing variables in test data 
  testData.continuousTruth = testData.continuous;
  testData.discreteTruth = testData.discrete;
  [D,N] = size(testData.continuous);
  miss = rand(D,N)<missProb;
  testData.continuous(miss) = NaN;
  [D,N] = size(testData.discrete);
  miss = rand(D,N)<missProb;
  testData.discrete(miss) = NaN;

