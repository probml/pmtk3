function [w, sigma, logpostTrace]=linregFitLassoEm(X, y, lambda)
% Fits the  lasso model using EM

[w,sigma,logpostTrace] = linregFitSparseEm(X, y, 'laplace', 'lambda', lambda);
end

