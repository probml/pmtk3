function y = drange(x, dim)
% Data Range
if nargin < 2, dim = 1; end
y = max(x,[],dim) - min(x,[],dim);
