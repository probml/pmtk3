function [tf,loc] = ismember_sorted_rows(a,s)
%ISMEMBER_SORTED_ROWS   True for member of sorted set of rows.
% TF = ISMEMBER_SORTED_ROWS(A,S) for the matrix A returns a column vector TF
% where TF(i) = 1 if A(i,:) is in S and 0 otherwise.
% A and S must be row-sorted and cannot contain NaN.
%
% [TF,LOC] = ISMEMBER_SORTED_ROWS(A,S) also returns an index array LOC where
% LOC(i) is the index in S which matches A(i) (highest if there are ties)
% or 0 if there is no such index.
%
% See also ISMEMBER, MATCH_SORTED_ROWS, INTERSECT_SORTED_ROWS, SETDIFF_SORTED_ROWS, UNION_SORTED_ROWS.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

if nargout < 2
  tf = ismember(a,s,'rows');
else
  [tf,loc] = ismember(a,s,'rows');
end
