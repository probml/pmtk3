function [Xtrain, ytrain, Xtest, ytest] = mnistLoad(classes, Ntrain)
% Load a subset of mnist corresponding to chosen classes
% Optionally take a subset of those to reduce training set size
% There are about 6000 training examples of each class, 1000 test

% This file is from pmtk3.googlecode.com


if nargin < 1, classes = 0:9; end
if nargin < 2, Ntrain = []; end

setSeed(0);
loadData('mnistAll');
%  trainndx = 1:60000; testndx =  1:10000;
trainndx = []; testndx = [];
for ci=1:length(classes)
  c = classes(ci);
  trainndx = [trainndx; find(mnist.train_labels==c)];
  testndx = [testndx; find(mnist.test_labels==c)];
end
perm = randperm(length(trainndx));
trainndx = trainndx(perm); % ensure classes are shuffled

% Optionally take smaller training subset
if ~isempty(Ntrain)
  trainndx = trainndx(1:Ntrain);
end

ntrain = length(trainndx);
ntest = length(testndx);
Xtrain = double(reshape(mnist.train_images(:,:,trainndx),28*28,ntrain)');
Xtest  = double(reshape(mnist.test_images(:,:,testndx),28*28,ntest)');
ytrain = (mnist.train_labels(trainndx));
ytest  = (mnist.test_labels(testndx));

restoreSeed;
end
