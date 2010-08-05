function logZ = dgmLogprob(dgm, varargin)
%% Estimate the log of the partition sum
% See dgmInferNodes for optional args
% (only handles a single observation sequence)
% Does not support dgm.infEngine = 'bp'
%%
[clamped, softEv, localEv] = process_options(varargin, ...
    'clamped', [], ...
    'softev' , [], ...
    'localev', []);

if ~isempty(clamped) && all(clamped)
    if isfield(dgm, 'factors')
        factors = dgm.factors;
    else
        factors = cpds2Factors(dgm.CPDs, dgm.G, dgm.CPDpointers);
    end
    doSlice = false;
    factors = addEvidenceToFactors(factors, clamped, doSlice); 
    logZ = log(prod(cellfun(@(f)nonzeros(f.T), factors)) + eps);
    return; 
end
% otherwise run inference 
localFacs = {}; 
if ~isempty(localEv)
    localFacs = softEvToFactors(localEvToSoftEv(dgm, localEv));
end
if ~isempty(softEv)
    localFacs = [localFacs(:); colvec(softEvToFactors(softEv))];
end

G = dgm.G;
if isfield(dgm, 'jtree')
    jtree = jtreeSliceCliques(dgm.jtree, clamped);
else
    doSlice = true;
    factors = cpds2Factors(dgm.CPDs, G, dgm.CPDpointers);
    factors = addEvidenceToFactors(factors, clamped, doSlice);
    nstates = cellfun(@(f)f.sizes(end), factors); 
    jtree   = jtreeCreate(cliqueGraphCreate(factors, nstates, G));
end
[jtree, logZlocal] = jtreeAddFactors(jtree, localFacs);
[jtree, logZ] = jtreeCalibrate(jtree);
logZ = logZ + logZlocal; 
end