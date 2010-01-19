function [Csmall,idx] = filtercell(Cbig,fn)
% Returns in Csmall only those cells c, from Cbig, for which fn(c) is true.
   
    idx = find(cellfun(fn,Cbig));
    Csmall = Cbig(idx);
end