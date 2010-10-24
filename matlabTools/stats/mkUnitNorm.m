function [X, s] = mkUnitNorm(X, s)
% Make each column of X be norm 1
% ie., sum_i x(i,j)^2 = 1 (so var(X(:,j),1)=1/n)
% If s is omitted, it is computed from X and returned for use at test time

% This file is from pmtk3.googlecode.com


if nargin < 2, s = []; end
[n p] = size(X);
if isempty(s)
  s = sqrt(sum(X.^2));
end
%X = X./repmat(s, n, 1);
X = bsxfun(@rdivide,X,s);

end
