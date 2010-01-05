function [tf,loc] = ismember_sorted(a,s)
%ISMEMBER_SORTED   True for member of sorted set.
% ISMEMBER_SORTED(A,S) for the vector A returns an array of the same size as A
% containing 1 where the elements of A are in the set S and 0 otherwise.
% A and S must be sorted and cannot contain NaN.
%
% [TF,LOC] = ISMEMBER_SORTED(A,S) also returns an index array LOC where
% LOC(i) is the index in S which matches A(i) (highest if there are ties)
% or 0 if there is no such index.
%
% See also ISMEMBER, MATCH_SORTED, INTERSECT_SORTED, SETDIFF_SORTED, UNION_SORTED.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

% The internal function ismembc comes from ismember.m
% It requires non-sparse arrays.
a = full(a);
s = full(s);
if nargout < 2
  tf = ismembc(a,s);
else
  loc = ismembc2(a,s);
  tf = (loc > 0);
end
