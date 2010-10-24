function [M, counts] = partitionedMean(X, y, C)
% Group the rows of X according to the class labels in y and take the mean of each group
%
% X  - an n-by-d matrix of doubles
% y  - an n-by-1 vector of ints in 1:C
% C  - (optional) the number of classes, (calculated if not specified)
%
% M  - a C-by-d matrix of means. 
% counts(i) = sum(y==i)
%
% See also partitionedSum

% This file is from pmtk3.googlecode.com


if nargin < 3
    C = nunique(y);
end
if 1
  d = size(X,2);
  M = zeros(C, d);
  for c=1:C
    ndx = (y==c);
    M(c, :) = mean(X(ndx, :));
  end
  counts = histc(y, 1:C);
else
  % fancy vectorized version
  if isOctave
    S = bsxfun(@eq, (1:C)', y');
  else
    S = bsxfun(@eq, sparse(1:C)', y');       % C-by-n logical sparse matrix, (basically a one-of-K encoding transposed)
  end
  M = S*X;                                 % computes the sum, yielding a C-by-d matrix
  counts = histc(y, 1:C);
  M = bsxfun(@rdivide, M, counts);         % divide by counts to get mean
end

end




