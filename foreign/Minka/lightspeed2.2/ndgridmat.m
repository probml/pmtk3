function x = ndgridmat(varargin)
%NDGRIDMAT  Matrix of grid points.
% y = NDGRIDMAT(x1,x2,...) returns one matrix containing all grid points 
% as rows.  It is the same as concatenating the results of NDGRID.
% First dimension varies fastest:
% y(1,:) = [x1(1) x2(1) ...]
% y(2,:) = [x1(2) x2(1) ...]

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

d = length(varargin);
if d == 1
  x = varargin{1}(:);
  return;
end

len = zeros(1,d);
for i = 1:d
  len(i) = length(varargin{i});
end
n = prod(len);
x = zeros(n,d);
k = 1;
for i = 1:d
  xi = varargin{i}(:);
  % might use reparray here
  x(:,i) = repmat(kron(xi, ones(k,1)), n/k/len(i), 1);
  k = k * len(i);
end
