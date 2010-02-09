function [f,g,H] = logregL2NLLgradHess(w, X, y, alpha, offsetAdded)
% gradient and hessian of negative log posterior for logistic regression
% w should be d x 1  vector
% X is n x d
% y(i) = 0 or 1
% alpha is optional strength of L2 regularizer
% If offsetAdded, first entry of w is offset, first col of X is 1s

if nargin < 4,alpha = 0; end
mu = 1 ./ (1 + exp(-X*w)); % mu(i) = prob(y(i)=1|X(i,:))
if offsetAdded, w(1) = 0; end % don't include offset in regularizer
negLogPrior =  alpha/2*sum(w.^2);
f = -sum( (y.*log(mu+eps) + (1-y).*log(1-mu+eps))) + negLogPrior;
g = []; H  = [];
if nargout > 1
   g = X'*(mu-y) + alpha*w;
end
if nargout > 2
   S = diag(mu .* (1-mu)); 
   H = X'*S*X + lambda*eye(length(w));
end
end