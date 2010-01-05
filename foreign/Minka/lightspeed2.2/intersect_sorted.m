function c = intersect_sorted(a,b)
%INTERSECT_SORTED     Set intersection between sorted sets.
% INTERSECT_SORTED(A,B) when A and B are vectors returns the values common
% to both A and B.  A and B must be sorted and unique, and the result will be
% sorted and unique.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

c = a(ismember_sorted(a,b));
