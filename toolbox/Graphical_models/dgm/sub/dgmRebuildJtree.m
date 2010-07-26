function dgm = dgmRebuildJtree(dgm, varargin)
%% Rebuild the precomputed, (uncalibrated) jtree
%
%%
factors = cpds2Factors(dgm.CPDs, dgm.G, dgm.CPDpointers);
dgm.jtree = jtreeCreate(cliqueGraphCreate(factors, dgm.nstates, dgm.G), varargin{:});
dgm.factors = factors;

end