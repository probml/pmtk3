function loc = match(x,tab)
%MATCH   Location of matches in a set.
% MATCH(x,tab) returns loc such that tab(loc(i)) = x(i).
% If x(i) is not in tab, loc(i) = 0.
%
% This function is a special case of ISMEMBER.

[dummy,loc] = ismember(x,tab);
