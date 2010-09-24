function p = gaussProb(X, mu, Sigma)
% Multivariate Gaussian distribution, pdf
% X(i,:) is i'th case
% *** In the univariate case, Sigma is the variance, not the standard
% deviation! ***

% This file is from pmtk3.googlecode.com


d = size(Sigma, 2);
X  = reshape(X, [], d);  % make sure X is n-by-d and not d-by-n
X = bsxfun(@minus, X, rowvec(mu));
logp = -0.5*sum((X/(Sigma)).*X, 2); 
logZ = (d/2)*log(2*pi) + 0.5*logdet(Sigma);
logp = logp - logZ;
p = exp(logp);        

end
