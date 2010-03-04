function [T, F] = partitionCell(C, fn)
% Partition the cell array C into those elements c for fn(c) returns true, 
% and those for which it returns false, (in that order). 

ndx = cellfun(fn, C); 
T   = C(ndx);
F   = C(~ndx); 


end