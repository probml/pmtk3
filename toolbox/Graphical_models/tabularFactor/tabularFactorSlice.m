function Tsmall = tabularFactorSlice(Tbig, visVars, visValues)
% Slice a tabular factor
% Return Tsmall(hnodes) = Tbig(visNodes=visValues, hnodes=:)
% visVars are global names, which are looked up in the domain
if isempty(visVars),
    Tsmall = Tbig;
    return;
end

visVars = rowvec(visVars);
visValues = rowvec(visValues);
H = setdiffPMTK(Tbig.domain, visVars);
d = length(Tbig.domain);
Vndx = lookupIndices(visVars, Tbig.domain);
ndx = mk_multi_index(d, Vndx, visValues);

Ts = squeeze(Tbig.T(ndx{:}));
Tsmall = tabularFactorCreate(Ts, H);

end