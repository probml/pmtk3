%% Check that fitting L2-regularized logisitc regression using SVD trick
%% is equivalent to standard method.

% This file is from pmtk3.googlecode.com


setSeed(0);
N = 10; D = 2;
X = randn(N,D);
y = sampleDiscrete([0.25 0.25 0.25 0.25], N,1);
lambda = 1;
[ model1 ] = logregFitL2Dual( X, y, lambda);
[ model2 ] = logregFit(X, y, 'regType', 'L2', 'lambda', lambda);
assert(approxeq(model1.w, model2.w))

