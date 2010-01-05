function loc = match_sorted_rows(a,s)
%MATCH_SORTED_ROWS   Location of matches in sorted rows.
% MATCH_SORTED_ROWS(A,S) returns LOC such that S(LOC(i),:) = A(i,:).
% If A(i,:) is not in S, LOC(i) = 0.
% S must be sorted and unique.
%
% This function is a special case of ISMEMBER_SORTED_ROWS.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

[tf,loc] = ismember_sorted_rows(a,s);
