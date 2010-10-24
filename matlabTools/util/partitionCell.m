function [T, F, ndx] = partitionCell(C, fn)
% Partition a cell into two according to a binary function
% Partition the cell array C into those elements c for fn(c) returns true, 
% and those for which it returns false, (in that order). 

% This file is from pmtk3.googlecode.com


ndx = cellfun(fn, C); 
T   = C(ndx);
F   = C(~ndx); 


end
