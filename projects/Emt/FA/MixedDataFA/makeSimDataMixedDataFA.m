function [trainData, testData, params] = makeSimDataMixedDataFA(N)
% [TRAINDATA, TESTDATA, PARAMS] = makeSimDataMixedDataFA(N) makes simulated data
% for mixedDataFA with N data points
%
% Written by Emtiyaz, CS, UBC
% Modified on June 09, 2010

  missProb = 0.3;
  Dz = 2;
  mean_ = [5 -5]';% -5 -5]';
  covMat = eye(Dz);
  z = repmat(mean_,1,N) + chol(covMat)*randn(Dz,N);
  Dc = 5;
  nClass = 2*ones(10,1);%[3 2 4];
  noiseCovMat = 0.01*eye(Dc);%abs(diag(randn(Dc,1)));
  Bc = rand(Dc,Dz);
  
  % generate data
  yc = Bc*z + chol(noiseCovMat)*randn(Dc,N);
  %yc = yc - repmat(mean(yc,2), 1, N);

  Bm = [];
  for c = 1:length(nClass)
    Bmc = rand(nClass(c)-1,Dz);
    p = [exp(Bmc*z); ones(1,N)];
    pMult = p./repmat(sum(p,1),nClass(c),1);
    yd(c,:) = sum(repmat([1:nClass(c)],N,1).*mnrnd(1,pMult'),2);
    Bm = [Bm; Bmc];
  end
 
  % model parameters structure
  params.nClass = nClass;
  params.mean = mean_;
  params.covMat = covMat;
  params.noiseCovMat = noiseCovMat;
  params.betaMult = Bm;
  params.betaCont = Bc;

  % split test and train data
  ratio = .7;
  [trainData, testData] = splitData(yc,yd,ratio);

%{
  % introduce missing variables in test data 
  testData.continuousTruth = testData.continuous;
  testData.discreteTruth = testData.discrete;
  [D,N] = size(testData.continuous);
  miss = rand(D,N)<missProb;
  testData.continuous(miss) = NaN;
  [D,N] = size(testData.discrete);
  miss = rand(D,N)<missProb;
  testData.discrete(miss) = NaN;
  %}

