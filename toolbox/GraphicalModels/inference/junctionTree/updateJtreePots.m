function jtree = updateJtreePots(jtree, factors)
% Rebuild the precomputed jtree after model params have changed
% The jtree structure does not change, just the clique potentials.

% This file is from pmtk3.googlecode.com

ncliques = numel(jtree.cliques);
factorLookup = jtree.factorLookup;
nstates = jtree.nstates;
clqs = jtree.clqs;
cliques = cell(1, ncliques);
% cliques are clique potnetials (tabular factors)
% clqs are list of nodes (int vec)
factors = rowvec(factors);
for c=1:ncliques
    ndx        = clqs{c};
    T          = tabularFactorCreate(onesPMTK(nstates(ndx)), ndx);
    tf         = [{T} factors(factorLookup(:, c))];
    cliques{c} = tabularFactorMultiply(tf);
end
jtree.cliques = cliques;

 
end

