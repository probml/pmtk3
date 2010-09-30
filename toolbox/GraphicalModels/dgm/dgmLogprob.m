function logZ = dgmLogprob(dgm, varargin)
%% Logprob of data
% If every node is clamped, we just multiply all the CPDs.
% If we have missing data, we run inference.
% See dgmInferNodes for optional args
% (only handles a single observation sequence)
% Uses jtree for inference. Use dgmInferNodes if you want to use
% e.g. approximate inference. 
%%

% This file is from pmtk3.googlecode.com

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
    %logZ = log(prod(cellfun(@(f)nonzeros(f.T), factors)) + eps);
    % KPM 29Sep10
    logZ = sum(log(cellfun(@(f)nonzeros(f.T), factors) + eps));
    return; 
end
% otherwise run inference 
% KPM 29Sep10: just call any inference method, not necessarily jtree
[bel, logZ] = dgmInferQuery(dgm, {}, varargin{:}); %#ok


%{
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
%}

end
