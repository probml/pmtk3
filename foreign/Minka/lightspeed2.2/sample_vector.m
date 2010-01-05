function x = sample_vector(p,col)
%SAMPLE_VECTOR    Sample from multiple categorical distributions.
% X = SAMPLE_VECTOR(P) returns a row vector of cols(P) integers, where
% X(I) = SAMPLE(P(:,I)).
%
% X = SAMPLE_VECTOR(P,COL) returns a row vector of length(COL) integers, where
% X(I) = SAMPLE(P(:,COL(I))).
% This is equivalent to SAMPLE_VECTOR(P(:,COL)), but faster.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

cdf = cumsum(p);
if nargin >= 2
  cdf = cdf(:,col);
end
if any(cdf(end,:) <= 0)
  error('distribution is all zeros');
end
u = rand(1,cols(cdf)).*cdf(end,:);
x = col_sum(cdf < repmat(u,rows(cdf),1)) + 1;
