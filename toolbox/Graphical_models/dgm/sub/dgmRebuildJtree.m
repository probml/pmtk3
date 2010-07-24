function dgm = dgmRebuildJtree(dgm, precomputeJtree)
%% Rebuild the precomputed, (uncalibrated) jtree
% If precomputeJtree is false, the invalidated  jtree is simply removed, 
% not rebuilt. 
%%
if nargin < 2, precomputeJtree = true; end
if isfield(dgm, 'jtree'), dgm = rmfield(dgm, 'jtree'); end
if isfield(dgm, 'factors'), dgm = rmfield(dgm, 'factors'); end

if precomputeJtree 
    factors = cpds2Factors(dgm.CPDs, dgm.G, dgm.CPDpointers);
    dgm.jtree = jtreeCreate(factorGraphCreate(factors, dgm.nstates, dgm.G));
    dgm.factors = factors;
end

end