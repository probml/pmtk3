function [c,a_match,b_match] = union_sorted_rows(a,b)
%UNION_SORTED_ROWS   Set union of sorted sets of row vectors.
% UNION_SORTED_ROWS(A,B) where A and B are matrices returns the combined rows
% from A and B with no repetitions.  Rows of A (and B) must be sorted and 
% unique, and the resulting rows will be sorted and unique.
%
% [C,A_MATCH,B_MATCH] = UNION_SORTED_ROWS(A,B) also returns
%   A_MATCH = MATCH_SORTED_ROWS(A,C)
%   B_MATCH = MATCH_SORTED_ROWS(B,C)
%
% Examples:
%   union_sorted_rows([10 20; 30 40], [30 40; 50 60])
%   [c,a_match,b_match] = union_sorted_rows([10 20; 30 40], [30 40; 50 60])

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

if nargout <= 1
  c = sortrows([a(~ismember_sorted_rows(a,b),:); b]);
else
  [tf,loc] = ismember_sorted_rows(a,b);
  [c,i] = sortrows([a(~tf,:); b]);
  nc = rows(c);
  nb = rows(b);
  na = rows(a);
  b_match = i((nc-nb+1):nc);
  a_match = zeros(1,na);
  a_match(~tf) = i(1:(nc-nb));
  a_match(tf) = b_match(loc(tf));
end
