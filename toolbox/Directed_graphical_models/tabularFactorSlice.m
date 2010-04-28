function Tsmall = tabularFactorSlice(Tbig, visVars, visValues)
% Return Tsmall(hnodes) = Tbig(visNodes=visValues, hnodes=:)
% visVars are global names, which are looked up in the domain
if isempty(visVars),
    Tsmall = Tbig;
    return;
end
d = length(Tbig.domain);
Vndx = lookupIndices(visVars, Tbig.domain);
ndx = mk_multi_index(d, Vndx, visValues);
Tsmall = squeeze(Tbig.T(ndx{:}));
H = setdiffPMTK(Tbig.domain, visVars);
Tsmall = tabularFactorCreate(Tsmall, H);
end