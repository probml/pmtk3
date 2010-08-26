function fac = cpt2Factor(CPT, G, i)
%% Convert a CPT to a tabularFactor
family  = [rowvec(parents(G, i)), i];
fac = tabularFactorCreate(CPT, family);
end