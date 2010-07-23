function dgm = dgmRebuildJtree(dgm, precomputeJtree)
%% Rebuild the precomputed, (uncalibrated) jtree
% If precomputeJtree is false, the invalidated  jtree is simply removed, 
% not rebuilt. 
%%
if isfield(dgm, 'jtree'), dgm = rmfield(dgm, 'jtree'); end
if isfield(dgm, 'factors'), dgm = rmfield(dgm, 'factors'); end

if precomputeJtree && strcmpi(dgm.infEngine, 'jtree'); 
    factors = cpds2Factors(dgm.CPDs, dgm.G, dgm.CPDpointers);
    model.jtree = jtreeCreate(factorGraphCreate(factors, dgm.nstates, dgm.G));
    model.factors = factors;
end

end