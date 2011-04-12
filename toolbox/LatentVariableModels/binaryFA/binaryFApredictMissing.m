function [yhat, postPred,loglik] = imputeBinaryVectorPCA(y, W, b)
% y(i) in {0,1,NaN} where NaN represents missing data
% W,b are learned using tippingEM (from fully observed bit vectors)
% yhat(i) in {0,1}
% postPred(i) = p(y(i)=1)
% loglik = log p(yobs)

% This file is from pmtk3.googlecode.com


[mu, Sigma, lambda, loglik] = varInferLogisticGaussCanonical(y(:), W, b);
[L p]= size(W);
X = [b(:) W']; % p * (L+1)
mu1 = [1;mu];
Sigma1 = zeros(L+1,L+1);
Sigma1(2:end,2:end) = Sigma;
postPred = sigmoidTimesGauss(X, mu1, Sigma1);
yhat = postPred  > 0.5;

