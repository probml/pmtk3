function fac = cpt2Factor(CPT, G, i)
%% Convert a CPT to a tabularFactor

% This file is from pmtk3.googlecode.com

family  = [rowvec(parents(G, i)), i];
fac = tabularFactorCreate(CPT, family);
end
