function [Csmall, idx] = filterCell(Cbig,fn)
% Keep only those elements c, of a cell array for which fn(c) is true

idx = find(cellfun(fn, Cbig));
Csmall = Cbig(idx);
end