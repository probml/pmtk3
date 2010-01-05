function [y,L] = normalizeLogspace(x)
% Normalize in logspace while avoiding underflow.
% Each *row* of x is a log discrete distribution.
% y(i,:) = x(i,:) - logsumexp(x,2) = x(i) - log[sum_c exp(x(i,c)]
% L is the log normalization constant
% eg [post, L] = exp(normalizeLogspace(logprior + loglik))

L = logsumexp(x, 2);
%y = x - repmat(L, 1, size(x,2));
y = bsxfun(@minus, x, L);
 
end