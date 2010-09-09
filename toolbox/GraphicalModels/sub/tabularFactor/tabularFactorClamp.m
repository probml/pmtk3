function clampedFac = tabularFactorClamp(Tfac, visVars, visValues)
% Clamp a tabular factor
%%

% This file is from pmtk3.googlecode.com

if isempty(visVars)
    clampedFac = Tfac; 
    return;
end
visVars = rowvec(visVars);
visValues = rowvec(visValues);
domain = Tfac.domain;
T = Tfac.T;
d = length(domain);
Vndx = lookupIndices(visVars, domain);
ndx = mk_multi_index(d, Vndx, visValues);
TT = zeros(size(T)); 
TT(ndx{:}) = T(ndx{:}); 
clampedFac = tabularFactorCreate(TT, domain);

end
