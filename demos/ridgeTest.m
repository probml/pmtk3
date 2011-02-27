%% Compare PMTK ridge with stats toolbox
% PMTKneedsStatsToolbox ridge
%%

% This file is from pmtk3.googlecode.com

requireStatsToolbox
X = loadData('caterpillar'); % from http://www.ceremade.dauphine.fr/~xian/BCS/caterpillar
y = log(X(:,11)); % log number of nests
X = X(:,1:10);
[n,d] = size(X);


%% MLE
[model] = linregFit(X, y) 
X1 = [ones(size(X,1),1) X];
what = X1\y;
assert(approxeq(model.w, what))

%% MAP with Gaussian prior
lambda = 0.1;
%XS = standardize(X);
pp = preprocessorCreate('addOnes', true);
[model] = linregFit(X, y, 'regType', 'L2', 'lambda', lambda, 'preproc', pp);
% Check matches stats toolbox
what = ridge(y, X, lambda, 0);
what'
model.w'

%assert(approxeq(model.w, what))

