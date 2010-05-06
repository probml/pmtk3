function p = gausscdf(X, mu, Sigma)
% Multivariate Gaussian cdf.
% X(i,:) is i'th case
p = cumsum(gausspdf(X, mu, Sigma)); 
end