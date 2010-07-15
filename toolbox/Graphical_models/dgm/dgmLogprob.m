function logZ = dgmLogprob(dgm, varargin)
%% Estimate the log of the partition sum
% See dgmInferNodes for optional args
%%
[clamped, softev, localev] = process_options(varargin, ...
    'clamped', [], ...
    'softev' , [], ...
    'localev', []);

localFacs = dgmEv2LocalFacs(dgm, localev, softev);
G = dgm.G;

if isfield(dgm, 'jtree')
    jtree = jtreeSliceCliques(dgm.jtree, clamped);
else
    doSlice = true;
    factors = cpds2Factors(dgm.CPDs, G, dgm.CPDpointers);
    factors = addEvidenceToFactors(factors, clamped, doSlice);
    jtree   = jtreeInit(factorGraphCreate(factors, G));
end
jtree = jtreeAddFactors(jtree, localFacs);
[jtree, logZ] = jtreeCalibrate(jtree);
end