function c = setdiff_sorted(a,b)
%SETDIFF_SORTED   Set difference between sorted sets.
% SETDIFF_SORTED(A,B) when A and B are vectors returns the values
% in A that are not in B.  A and B must be sorted and unique, and the result 
% will be sorted and unique.

c = a(~ismember_sorted(a,b));
