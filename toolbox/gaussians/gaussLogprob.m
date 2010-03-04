function logp = gaussLogprob(model, X)
% Multivariate Gaussian distribution, log pdf
% model is a struct with fields mu and Sigma
% X(i,:) is i'th case
% In the univariate case, Sigma is the variance, not the SD. 

mu = model.mu; Sigma = model.Sigma; 
d = size(Sigma, 2);
X = reshape(X, [], d);
X = bsxfun(@minus, X, rowvec(mu));
logp = -0.5*sum((X*inv(Sigma)).*X, 2); 
logZ = (d/2)*log(2*pi) + 0.5*logdet(Sigma);
logp = logp - logZ;
        
if 0 % test
  % this test expects uncentered X - but to allow for matlab's automatic
  % inplace modification, we use X = bsxfun(@minus, X, rowvec(mu)); not
  % Xc. Just rename X if you want to test. 
  logp2 = log(mvnpdf(X, rowvec(mu), Sigma)); %#ok
  assert(approxeq(logp, logp2))
end

end