%% Classify some MNIST digits using a deepBelNet
%PMTKauthor Andrej Karpathy
%PMTKmodified Kevin Murphy
%PMTKreallySlow

% This file is from pmtk3.googlecode.com


%% Data
setSeed(0);
clear all

if 0
  %all datasets above must conform to the following naming conventions:
  %for training: 'data' NxD, 'labels' Nx1
  %for testing : 'testdata' NxD, 'testlabels' Nx1
  load mnist_classify.mat
  Xtrain = data; ytrain1to10 = labels;
  Xtest = testdata; ytest1to10 = testlabels;
else
  Ntrain = 5000; Ntest = 1000; keepSparse = false;
  binarize = false;
  [Xtrain, ytrain, Xtest, ytest] = setupMnist('binary', binarize, 'ntrain',...
    Ntrain,'ntest', Ntest,'keepSparse', keepSparse);
  ytest1to10 = ytest+1;
  ytrain1to10 = ytrain+1;
end


%% DBNs
%Nhidden =  [500 500 2000];
Nhidden =  [500 500 500];
opts.verbose = true;
opts.maxepoch = 20;
opts.penalty = 2e-4; %0.001;

for i=1:numel(Nhidden)
  tic
  models{i} = deepBelNetFit(Xtrain, Nhidden(1:i), ytrain1to10, opts);
  trainTime(i) = toc;
  yhat1to10 = deepBelNetPredict(models{i}, Xtest);
  errors = (yhat1to10 ~= ytest1to10);
  nlayers(i) = numel(models{i}.layers)
  errRate(i) = sum(errors)/length(yhat1to10)
  fprintf('RBM with %d hidden layers: errRate %5.3f, train time %5.3f\n', ...
    nlayers(i), errRate(i)*100, trainTime(i))
  nparams(i) = models{i}.nparams;
end

    
figure; plot(errRate*100, 'ro-', 'linewidth', 2);
xlabel('num layers'); ylabel('misclassification rate')

figure; plot(trainTime, 'ro-', 'linewidth', 2);
xlabel('num layers'); ylabel('training time (seconds)')


%% Make a wide but shallow RBM
% This has same num params as the deep model
D = size(Xtrain,2);
nh = ceil(nparams(end)/D);
optsy = opts;
optsy.y = ytrain1to10;
i=numel(Nhidden)+1;
tic
models{i} = rbmFit(Xtrain, nh,  optsy);
trainTime(i) = toc;
yhat1to10 = rbmPredict(models{i}, Xtest);
errors = (yhat1to10 ~= ytest1to10);
nlayers(i) = 1;
errRate(i) = sum(errors)/length(yhat1to10)
fprintf('RBM with %d hidden layers: errRate %5.3f, train time %5.3f\n', ...
  nlayers(i), errRate(i)*100, trainTime(i))
nparams(i) = models{i}.nparams;


    
