function catFAtest()
% Categorical factor analysis - check the code is syntactically correct
% We create some synthetic data with NaNs, fit the model,
% infer the latents, and impute the missing entries

clear all
setSeed(16)
% generate data
[trainData,testData,simParams] = makeSimDataMixedDataFA(100);
nClass = simParams.nClass;
% introduce missing variables in train data
missProb = 0.1;
trainData.continuousTruth = trainData.continuous;
trainData.discreteTruth = trainData.discrete;
[D,N] = size(trainData.continuous);
miss = rand(D,N)<missProb;
trainData.continuous(miss) = NaN;
[D,N] = size(trainData.discrete);
miss = rand(D,N)<missProb;
trainData.discrete(miss) = NaN;


Dz = 2;
[model, loglikTrace] = catFAfit(trainData.discrete', trainData.continuous', Dz);

[mu, Sigma, loglik] = catFAinferLatent(model, testData.discrete', testData.continuous')

[predD, predC] = catFApredictMissing(model,  testData.discrete', testData.continuous')

  
end

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


end

function [trainData, testData, idx] = splitData(yc, yd, ratio) 
% splits data into training and testing set
% yc is the continuous data, yd is discrete data
% ratio is the split ratio

  [Dc,Nc] = size(yc);
  [Dd,Nd] = size(yd);
  N = max(Nc,Nd);
  nTrain = ceil(ratio*N);
  idx = randperm(N);
  if Dc>0
    testData.continuous = yc(:,idx(nTrain+1:end));
    trainData.continuous = yc(:,idx(1:nTrain));
  else
    testData.continuous = [];
    trainData.continuous = [];
  end
  if Dd>0
    testData.discrete = yd(:,idx(nTrain+1:end));
    trainData.discrete = yd(:,idx(1:nTrain));
  else
    testData.discrete = [];
    trainData.discrete = [];
  end
 
end

