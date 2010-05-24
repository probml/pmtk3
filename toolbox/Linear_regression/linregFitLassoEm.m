function [w, sigma, logpostTrace]=linregFitLassoEm(X, y, lambda)
% Fits the  lasso model using EM

[w,sigma,logpostTrace] = linregSparseFitEm(X, y, 'laplace', 'lambda', lambda);
end

