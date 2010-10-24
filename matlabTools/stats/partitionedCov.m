function Sigma = partitionedCov(X, y, C)
%% Partition the rows of X according to y and take the cov of each group
% C is the number of states in y, and is calcuated if not specified.
% X is n-by-d, y is n-by-1 and in 1:C
% Sigma is of size d-by-d-by-C
% See also partitionedMean, partitionedSum
%%

% This file is from pmtk3.googlecode.com

if nargin < 3
    C = nunique(y);
end
[n, d] = size(X);
Sigma = zeros(d, d, C);
for c=1:C
    Sigma(:, :, c) = cov(X(y==c, :));
end
end
