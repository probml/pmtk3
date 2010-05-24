function p = gausscdf(X, mu, sigma)
% Univariate Gaussian cdf
% sigma is the variance, not standard deviation
% X(i,:) is i'th case

if nargin < 3, 
    mu = 0; 
    sigma = 1;
end
z = (X-mu) ./ sqrt(sigma);
p = 0.5 * erfc(-z ./ sqrt(2));


end