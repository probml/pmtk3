function map = dgmMap(dgm, varargin)
%% Find the mode, (map assignment)
% Optional named args are the same as for dgmInferNodes
% This uses jtree.
%

% This file is from pmtk3.googlecode.com

[clamped, softEv, localEv] = process_options(varargin, ...
    'clamped', [], ...
    'softev' , [], ...
    'localev', []);
localFacs = {};
if ~isempty(localEv)
    localFacs = softEvToFactors(localEvToSoftEv(dgm, localEv));
end
if ~isempty(softEv)
    localFacs = [localFacs(:); colvec(softEvToFactors(softEv))];
end
G = dgm.G;
if isfield(dgm, 'jtree')
    jtree     = jtreeSliceCliques(dgm.jtree, clamped);
else
    doSlice = true;
    factors = cpds2Factors(dgm.CPDs, G, dgm.CPDpointers);
    factors = addEvidenceToFactors(factors, clamped, doSlice);
    nstates = cellfun(@(f)f.sizes(end), factors);
    jtree   = jtreeCreate(cliqueGraphCreate(factors, nstates, G));
end
jtree = jtreeAddFactors(jtree, localFacs);
map   = jtreeFindMap(jtree);
if ~isempty(clamped)
    map(find(clamped)) = nonzeros(clamped); %#ok 
end
end
