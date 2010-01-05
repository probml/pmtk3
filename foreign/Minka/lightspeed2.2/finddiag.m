function i = finddiag(A,k)
%FINDDIAG    Index elements on the diagonal.
% FINDDIAG(A) returns the indices of the diagonal of A.
% FINDDIAG(A,K) returns the indices of the K-th diagonal of A.
%
% See also DIAG, SETDIAG.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

if nargin < 2
  k = 0;
end
n = length(A);
if k >= 0
  i = (k*n+1):(n+1):(n^2);
else
  i = (1-k):(n+1):(n*(n+k));
end
