function logZ = dgmLogprob(dgm, varargin)
%% Estimate the log of the partition sum
% See dgmInferNodes for optional args
% (only handles a single observation sequence)
%%
[clamped, softEv, localEv] = process_options(varargin, ...
    'clamped', [], ...
    'softev' , [], ...
    'localev', []);

if all(clamped)
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
    localFacs = softEvToFactors(dgmLocalEvToSoftEv(dgm, localEv));
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
    jtree   = jtreeInit(factorGraphCreate(factors, G));
end
jtree = jtreeAddFactors(jtree, localFacs);
[jtree, logZ] = jtreeCalibrate(jtree);
end