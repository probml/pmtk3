function [w, sigma, logpostTrace]=linregFitGroupLassoEm(X, y, groups, lambda)
% Fits the grouped lasso model using EM

[w,sigma,logpostTrace] = linregSparseFitEm(X, y, 'groupLasso', ...
  'lambda', lambda, 'groups', groups);
end

