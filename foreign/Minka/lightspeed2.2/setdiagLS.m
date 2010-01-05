function A = setdiag(A,v,k)
%SETDIAG  Modify the diagonal(s) of a matrix.
% SETDIAG(A,V) returns a copy of A where the main diagonal is set to V.
% V can be a scalar or vector.
% SETDIAG(A,V,K) sets the K-th diagonal to V.  The K-th diagonal has length
% N-ABS(K).
%
% See also DIAG, FINDDIAG.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

if nargin < 3
  k = 0;
end
A(finddiag(A,k)) = v;
