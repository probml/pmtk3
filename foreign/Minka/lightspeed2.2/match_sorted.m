function loc = match_sorted(a,s)
%MATCH_SORTED   Location of matches in a sorted set.
% MATCH_SORTED(A,S) returns LOC such that S(LOC(i)) = A(i).
% If A(i) is not in S, LOC(i) = 0.
% S must be sorted and unique.
%
% This function is a special case of ISMEMBER_SORTED.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

loc = ismembc2(a,s);
