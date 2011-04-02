function [trainData, testData, params] = makeSimDataImm(N)

  %generate training data
  multProb =[0.5 0.5];
  nClass = [2 3 4];
  K = length(multProb);
  mean_ = [5 -5; -5 5]';
  covMat(:,:,1) = eye(size(mean_,1));
  covMat(:,:,2) = eye(size(mean_,1));
  missProb = 0.1;

  % generate continuous measurement
  for n = 1:N
    q(:,n) = mnrnd(1,multProb')';
    k(n) = find(q(:,n));
    yc(:,n) = mean_(:,k(n)) + chol(covMat(:,:,k(n)))*randn(length(mean_(:,k(n))),1);
  end
  % discrete measuremetns
  prob = [];
  for d = 1:length(nClass)
    p = rand(nClass(d), K); 
    prob1 = p./repmat(sum(p),nClass(d),1);
    for n = 1:N
      yd(d,n) = find(mnrnd(1,prob1(:,k(n))));
      ydT(d,n) = find(mnrnd(1,prob1(:,k(n))));
    end
    prob = [prob; prob1];
  end
  % model parameters structure
  params.mixProb = multProb;
  params.nClass = nClass;
  params.mean = mean_;
  params.covMat = covMat;
  params.prob = prob;

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

