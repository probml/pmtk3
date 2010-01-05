function [X,mu] = center(X, mu)
% CENTER Make each column be zero mean

if nargin < 2 || isempty(mu)
  mu = mean(X); % across columns (if matrix)
end
[n p] = size(X);
%X = X - repmat(mu, n, 1);
X = bsxfun(@minus, X, mu);

