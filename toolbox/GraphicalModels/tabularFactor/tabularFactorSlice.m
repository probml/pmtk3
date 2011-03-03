function Tsmall = tabularFactorSlice(Tbig, visVars, visValues)
% Slice a tabular factor
% Return Tsmall(hnodes) = Tbig(visNodes=visValues, hnodes=:)
% visVars are global names, which are looked up in the domain

% This file is from pmtk3.googlecode.com


%%
if isempty(visVars),
    Tsmall = Tbig;
    return;
end
domain = Tbig.domain;
H = setdiffPMTK(domain, visVars);
if isempty(H)
   % this is a tricky case - slicing would completely diminish the factor
   % which causes problems for e.g. pre-existing jtrees. Other solutions,
   % such as returning tabularFactorCreate(1, domain(end)) affect logZ
   % calculations.
   Tsmall = tabularFactorClamp(Tbig, visVars, visValues); 
   return; 
end
Tb = Tbig.T;

visVars = rowvec(visVars);
visValues = rowvec(visValues);

d = length(domain);
Vndx = lookupIndices(visVars, domain);
ndx = mk_multi_index(d, Vndx, visValues);


Ts = squeeze(Tb(ndx{:}));
Tsmall = tabularFactorCreate(Ts, H);

end
