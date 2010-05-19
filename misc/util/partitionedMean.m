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
%%
% This is a vectorized version of this code fragment:
%
% M = zeros(C, d);
% for c=1:C
%     ndx = find(y==c); 
%     M(c, :) = mean(X(ndx, :));
% end
% 
% counts = histc(y, 1:C);
%%

if nargin < 3
    C = nunique(y);
end

S = bsxfun(@eq, sparse(1:C)', y');       % C-by-n logical sparse matrix, (basically a one-of-K encoding transposed)
M = S*X;                                 % computes the sum, yielding a C-by-d matrix
counts = histc(y, 1:C);                  
M = bsxfun(@rdivide, M, counts);         % divide by counts to get mean

end




