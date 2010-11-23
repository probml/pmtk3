%% Classify some MNIST digits using a binary RBM
%PMTKauthor Andrej Karpathy
%PMTKmodified Kevin Murphy

% This file is from pmtk3.googlecode.com


setSeed(0);
Ntrain = 1000; Ntest = 100; keepSparse = false;
binarize = false;
[Xtrain, ytrain, Xtest, ytest] = setupMnist('binary', binarize, 'ntrain',...
    Ntrain,'ntest', Ntest,'keepSparse', keepSparse);
ytest1to10 = ytest+1;
ytrain1to10 = ytrain+1;

Nhidden = 100;
tic
model = rbmFit(Xtrain, Nhidden, 'y', ytrain1to10, ...
  'verbose', true, 'maxepoch', 20);
toc

yhat1to10 = rbmPredict(model, Xtest); 

errors = (yhat1to10 ~= ytest1to10);
fprintf('Error rate using RBM with %d hiddens is %5.3f\n', ...
    Nhidden, sum(errors)/length(yhat1to10));

%visualize weights
figure
rbmPlotImg(model.W);
title('learned weights');

%visualize the mislabeled cases. Note the transpose. Visualize assumes DxN
%as is the case for weights
figure
rbmPlotImg(Xtest(errors,:)');
title('classification mistakes for RBM with 100 hiddens');
drawnow;

