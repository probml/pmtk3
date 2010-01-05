function x = ndmax(x,dim)
% NDMAX    Multi-dimensional maximization.
% NDMAX(X,DIM) takes the maximum element along the dimensions in DIM,
% and squeezes the result.

% Written by Thomas P Minka
% (c) Microsoft Corporation. All rights reserved.

sz = size(x);
for i=1:length(dim)
  x = max(x, [], dim(i));
end
x = mysqueeze(x);
addflops(2*(prod(sz)-prod(size(x))));
