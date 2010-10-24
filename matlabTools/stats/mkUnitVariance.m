function [X, s] = mkUnitVariance(X, s)
% Make each column of X be variance 1
% ie., sum_i x(i,j)^2 = n (so var(X(:,j))=1)
% If s is omitted, it computed from X and returned for use at test time

% This file is from pmtk3.googlecode.com


if nargin < 2, s = []; end
if isempty(s)
  s = std(X);
  s((s<eps))=1;
end
n = size(X,1);
%X = X./repmat(s, [n 1]);
X = bsxfun(@rdivide,X,s);

end

