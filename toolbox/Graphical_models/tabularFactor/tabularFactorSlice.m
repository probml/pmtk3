function Tsmall = tabularFactorSlice(Tbig, visVars, visValues)
% Slice a tabular factor
% Return Tsmall(hnodes) = Tbig(visNodes=visValues, hnodes=:)
% visVars are global names, which are looked up in the domain

%%
if isempty(visVars),
    Tsmall = Tbig;
    return;
end
domain = Tbig.domain;
Tb = Tbig.T;
H = setdiffPMTK(domain, visVars);
if isempty(H); 
    Tsmall = tabularFactorCreate(ones(2, 1), Tbig.domain(end)); 
    return;
end
visVars = rowvec(visVars);
visValues = rowvec(visValues);

d = length(domain);
Vndx = lookupIndices(visVars, domain);
ndx = mk_multi_index(d, Vndx, visValues);


Ts = squeeze(Tb(ndx{:}));
Tsmall = tabularFactorCreate(Ts, H);

end