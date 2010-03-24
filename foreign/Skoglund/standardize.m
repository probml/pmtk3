function X = standardize(X)
% STANDARDIZE  Standardize the observations of a data matrix.
%    X = STANDARDIZE(X) centers and scales the observations of a data
%    matrix such that each variable (column) has unit variance.
%
% Author: Karl Skoglund, IMM, DTU, kas@imm.dtu.dk


[n p] = size(X);
X = centerCols(X);
X = X./(ones(n,1)*std(X,1));

end