%% Linreg frequentist caterpillar demo
%PMTKneedsStatsToolbox regress
%%

% This file is from pmtk3.googlecode.com

requireStatsToolbox
X = loadData('caterpillar'); % from http://www.ceremade.dauphine.fr/~xian/BCS/caterpillar
y = log(X(:,11)); % log numner of nests
X = X(:,1:10);

[w, stderr, pval, R2, sigma2, confint, Zs] = ...
  linregFrequentistSummary(y, X, [], true);

% use stats toolbox
[n d] = size(X);
XX = [ones(n,1) X];
[b, bint, r, rint, stats] = regress(y, XX);
% b(j) is coefficient j, bint(j,:) = lower and upper 95% conf interval
% r(i) = residual for case i, rint(i,:)  = lower and upper 95% conf interval
% stats = [Rsquared, Fstat, pval for Fstat, error variance]
assert(approxeq(b, w))
assert(approxeq(bint, confint))
assert(approxeq(stats(1), R2))
assert(approxeq(stats(4), sigma2))
