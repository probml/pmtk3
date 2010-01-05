function x = ndsum(x,dim)
% NDSUM    Multi-dimensional summation.
% NDSUM(X,DIM) sums out the dimensions in DIM, and squeezes the result.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

if 0
  % permutation takes too long
  x = permute_to_front(x,dim);
  sz = size(x);
  msz = sz(1:length(dim));
  ksz = sz(length(dim)+1:end);
  x = reshape(x,[prod(msz) ksz]);
  x = sum(x);
  x = mysqueeze(x);
else
  sz = size(x);
  for i=1:length(dim)
    x = sum(x, dim(i));
  end
  addflops(prod(sz)-numel(x));
  %x = mysqueeze(x);
  sz(dim) = [];
  x = reshape(x,[sz 1 1]);
end
