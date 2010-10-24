function [xtrain, ytrain, xtest, ytest] = makePolyData(n)

%error('deprecated')

% This file is from pmtk3.googlecode.com


% based on code by Romain Thibaux
% (Lecture 2 from http://www.cs.berkeley.edu/~asimma/294-fall06/)

%if nargin < 1, rng = 0:20; end
if nargin < 1, n = 21; end

randn('state', 654321);
w = [-1.5; 1/9];
%xtrain = (0:20)';
xtrain = linspace(0,20,n)';
xtest = (0:0.1:20)';
n = length(xtrain);
sigma2 = 4;
ytrueTrain = w(1)*xtrain+w(2)*xtrain.^2;
ytrain = ytrueTrain+sqrt(sigma2)*randn(n,1);

ytrueTest = w(1)*xtest+w(2)*xtest.^2;
ytest = ytrueTest +sqrt(sigma2)*randn(length(xtest),1);
