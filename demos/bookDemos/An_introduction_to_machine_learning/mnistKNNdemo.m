%% Classify the MNIST digits using a one nearest neighbour classifier and Euclidean distance
%
% Compare to mnist1NNdemo, which uses various tricks
% to scale things up 

% This file is from pmtk3.googlecode.com


loadData('mnistAll');
trainndx = 1:10000;
testndx =  1:1000;
ntrain = length(trainndx);
ntest = length(testndx);
Xtrain = double(reshape(mnist.train_images(:,:,trainndx),28*28,ntrain)');
Xtest  = double(reshape(mnist.test_images(:,:,testndx),28*28,ntest)');
ytrain = (mnist.train_labels(trainndx));
ytest  = (mnist.test_labels(testndx));
clear mnist trainndx testndx; % save space

tic
m = knnFit(Xtrain, ytrain, 1);
ypred = knnPredict(m, Xtest);
errorRate = mean(ypred ~= ytest);
fprintf('Error Rate: %.2f%%\n',100*errorRate);
t = toc; fprintf('Total Time: %.2f seconds\n',t);
