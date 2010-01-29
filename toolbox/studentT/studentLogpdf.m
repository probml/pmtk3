function logp = studentLogpdf(X, mu, Sigma, nu)
% Multivariate student T distribution, log pdf
% X(i,:) is i'th case
if length(mu)==1, X = X(:); end
[N d] = size(X);
M = repmat(mu(:)', N, 1); % replicate the mean across rows
X = X-M;
mahal = sum((X*inv(Sigma)).*X,2); %#ok
logc = gammaln(nu/2 + d/2) - gammaln(nu/2) - 0.5*logdet(Sigma) ...
   - (d/2)*log(nu) - (d/2)*log(pi);
logp = logc  -(nu+d)/2*log1p(mahal/nu);

if 0 % check that scalar case works
  if length(mu)==1
    x = X(:);
    s2 = Sigma^2;
    logc = gammaln(nu/2 + 0.5) - gammaln(nu/2) - 0.5*log(nu*pi*s2);
    logp2 = logc  -(nu+1)/2*log1p((1/nu)*((x-mu)/s2).^2);
    assert(approxeq(logp, logp2))
  end
end

if 0
  % compare to stats toolbox
   % this check only works if Sigma is a correlation matrix
  logp2 = log(mvtpdf(X, Sigma, nu));
  assert(approxeq(logp, logp2))
end


