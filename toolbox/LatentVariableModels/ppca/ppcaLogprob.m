function [logp, ll] = ppcaLogprob(X, W, mu, sigma2, evals, evecs)
% logp(i) = log N(X(i,:) | mu, C) where C = W W' + sigma^2 I(d)
% Based on code by Ian Nabney
mu = mu(:)';
[N d] = size(X);
[d K] = size(W);

U = evecs(:,1:K);
L = evals(1:K);
j = 1-sigma2./evals(1:K);
%J = diag(j);
%Cinv = (1/sigma2)*(eye(d) - U*J*U');
logdetC = (d-K)*log(sigma2) + sum(log(L));
%assert(approxeq(logdetC, -log(det(Cinv)))
%MM = repmat(mu, N, 1); % replicate the mean across rows
%mahal = sum(((X-MM)*Cinv).*(X-MM),2); 
diffs = X - repmat(mu, N, 1);
proj = diffs*U;
mahal = sum(diffs .* diffs, 2) - ...
   sum(proj .* repmat(j(:)', N,1) .* proj, 2);
mahal = mahal/sigma2;
logp = -0.5*mahal - (d/2)*log(2*pi) -0.5*logdetC;

if  nargout >= 2 % debugging - O(d^3) time
   C = W*W' + sigma2*eye(d);
   p = gaussProb(X, mu, C);
   ll = log(p);
   %assert(approxeq(logp, ll))
end

end