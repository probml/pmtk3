function [S, mu, sigma2] = standardizeCols(M, mu, sigma2)
% function S = standardize(M, mu, sigma2)
% Make each column of M be zero mean, std 1.
%
% If mu, sigma2 are omitted, they are computed from M

[nrows ncols] = size(M);

M = double(M);
if nargin < 2
  mu = mean(M);
  sigma2 = std(M);
  ndx = find(sigma2 < eps);
  sigma2(ndx) = 1;
end

S = M - repmat(mu, [nrows 1]);
if ncols > 0
S = S ./ repmat(sigma2, [nrows 1]);
end
