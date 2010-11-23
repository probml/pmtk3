%% MLP Classification Demo
% Based on Mark Schmidt's Demo from
% http://people.cs.ubc.ca/~schmidtm/Software/minFunc/minFunc.html#9
%%

% This file is from pmtk3.googlecode.com

H = [3, 6, 9];
for hi=1:length(H)
  nhidden = H(hi);
setSeed(0);
nVars = 2;
nInstances = 400;
options.Display = 'none';
options.MaxIter = 100;
[X,y] = makeData('classificationNonlinear',nInstances,nVars);
[N,D] = size(X);
X1 = [ones(N,1) X];
lambda = 1e-2;

model = mlpFit(X, y, 'nhidden', nhidden, 'lambda', lambda, ...
  'fitOptions', options, 'method', 'schmidt');
[yhat, py] = mlpPredict(model, X);

model1 = mlpFit(X, y, 'nhidden', nhidden, 'lambda', lambda, ...
  'fitOptions', options, 'method', 'netlab');
[yhat1, py1] = mlpPredict(model, X);

assert(approxeq(py, py1))

nerr = sum(yhat ~= y);

str = sprintf('mlp with %d hidden units, nerr = %d', model.nHidden, nerr);
plotDecisionBoundary(X, y, @(X)mlpPredict(model, X));
title(str);
printPmtkFigure(sprintf('mlpClassifH%d', nhidden));
end

