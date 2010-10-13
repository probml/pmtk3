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
for nlayers=1:numel(Nhidden)
  opts.verbose = true;
  opts.maxepoch = 20;
  opts.penalty = 0.01;
  tic
  H = Nhidden(1:nlayers);
  model = deepBelNetFit(Xtrain, H, ytrain1to10, opts);
  trainTime(nlayers) = toc;
  yhat1to10 = deepBelNetPredict(model, Xtest);
  errors = (yhat1to10 ~= ytest1to10);
  errRate(nlayers) = sum(errors)/length(yhat1to10);
  fprintf('RBM with %s hiddens: errRate %5.3f, train time %5.3f\n', ...
    num2str(H), errRate(nlayers), trainTime(nlayers))
end

figure; plot(errRate, 'ro-', 'linewidth', 2);
xlabel('num layers'); ylabel('misclassification rate')

