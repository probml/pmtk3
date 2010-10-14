%% Classify some MNIST digits using a deepBelNet
%PMTKauthor Andrej Karpathy
%PMTKmodified Kevin Murphy

setSeed(0);
clear all
Ntrain = 5000; Ntest = 1000; keepSparse = false;
binarize = false;
[Xtrain, ytrain, Xtest, ytest] = setupMnist('binary', binarize, 'ntrain',...
    Ntrain,'ntest', Ntest,'keepSparse', keepSparse);
ytest1to10 = ytest+1;
ytrain1to10 = ytrain+1;

Nhidden =  [500 500 2000];
opts.verbose = true;
opts.maxepoch = 20;
opts.penalty = 0.001;
model = deepBelNetFit(Xtrain, Nhidden, ytrain1to10, opts);
 
% Now extract shallower models
for i=1:3
  models{i} = model;
  models{i}.layers(i+1:end) = [];
end

for i=1:numel(models)
  yhat1to10 = deepBelNetPredict(models{i}, Xtest);
  errors = (yhat1to10 ~= ytest1to10);
  nlayers = numel(models{i}.layers);
  errRate(nlayers) = sum(errors)/length(yhat1to10);
  fprintf('RBM with %d hidden layers: errRate %5.3f, train time %5.3f\n', ...
    nlayers, errRate(nlayers), trainTime(nlayers))
end

figure; plot(errRate, 'ro-', 'linewidth', 2);
xlabel('num layers'); ylabel('misclassification rate')

