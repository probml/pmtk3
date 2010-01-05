function x = ndlogsumexp(x,dim)
% NDLOGSUMEXP    Sum over multiple dimensions in the log domain.
% ndlogsumexp(X,DIM) sums out the dimensions in DIM (using logsumexp), 
% and squeezes the result.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

sz = size(x);
for i=1:length(dim)
  x = logsumexp(x, dim(i));
end
nbig = prod(sz);
nsmall = prod(size(x));
addflops((nbig-nsmall)*(1+flops_exp) + nsmall*flops_log);
%x = mysqueeze(x);
sz(dim) = [];
x = reshape(x,[sz 1 1]);
