function logp = gaussLogpdf(X, mu, Sigma)
% Multivariate Gaussian distribution, log pdf
% X(i,:) is i'th case
if length(mu)==1, X = X(:); end
d = size(X,2);
XC = bsxfun(@minus,X,rowvec(mu));
logp = -0.5*sum((XC*inv(Sigma)).*XC,2); %#ok
logZ = (d/2)*log(2*pi) + 0.5*logdet(Sigma);
logp = logp - logZ;
        
if 0
  % check against stats toolbox
  logp2 = log(mvnpdf(X, rowvec(mu), Sigma));
  assert(approxeq(logp, logp2))
end
