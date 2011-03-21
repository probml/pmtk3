function dgm = dgmRebuildJtree(dgm, varargin)
% Rebuild the precomputed jtree after CPD params have changed
% The jtree structure does not change, just the clique potentials.

% This file is from pmtk3.googlecode.com


% In this implementation, we start from scratch,
% and ignore any existing jtree structure
%{
factors = cpds2Factors(dgm.CPDs, dgm.G, dgm.CPDpointers);
dgm.jtree = jtreeCreate(cliqueGraphCreate(factors, dgm.nstates, dgm.G), varargin{:});
dgm.factors = factors;
%}

 
if ~isfield(dgm, 'jtree')
  error('you must first build the jtree by calling dgmCreate')
end
factors = cpds2Factors(dgm.CPDs, dgm.G, dgm.CPDpointers);

dgm.jtree = updateJtreePots(dgm.jtree, factors);

%{
ncliques = numel(dgm.jtree.cliques);
factorLookup = dgm.jtree.factorLookup;
nstates = dgm.nstates;
clqs = dgm.jtree.clqs;
cliques = cell(1, ncliques);
% cliques are clique potnetials (tabular factors)
% clqs are list of nodes (int vec)
for c=1:ncliques
    ndx        = clqs{c};
    T          = tabularFactorCreate(onesPMTK(nstates(ndx)), ndx);
    tf         = [{T}; factors(factorLookup(:, c))];
    cliques{c} = tabularFactorMultiply(tf);
end
dgm.jtree.cliques = cliques;
dgm.factors = factors;
 %}

end

