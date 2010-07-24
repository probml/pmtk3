function [nodeBels, logZ] = dgmInferNodes(dgm, varargin)
%% Return all node beliefs (single marginals)
%% Inputs
%
% dgm    - a struct created by dgmCreate
%
%% Optional named inputs
%
% 'clamped'  - a sparse vector of size 1-by-nnodes.
%              clamped(t) = j means node t is clamped to state j
%              clamped(t) = 0 means node t is not clamped
%
% 'softev'   - softev(j, t) = p(v(t) | h(t) = j) where h(t) is
%              the t'th hidden node, and v(t) is its private evidence child.
%              softev can be  created by  mkSoftEvidence.
%              Use NaN columns for nodes without soft
%              evidence, and pad the ends of columns with NaNs for nodes
%              with nstates < max(nstates). softev is
%              max(nstates)-by-nnodes.
%
% 'localev'  - a d-by-nnodes matrix representing a (usually continuous)
%              observation sequence v(:,1:T), which will be converted to factors
%              using localCPDs specified to dgmCreate. Use NaNs for
%              unobserved nodes.
%
% * you can specify both softev and localev
%% Outputs
%
% nodeBels   - a cell array of tabularFactors representing the normalized
%              node beliefs (single marginals).
%
% logZ       - log of the partition sum (if this is all you want, use
%              dgmLogprob)
%% Setup
[clamped, softEv, localEv] = process_options(varargin, ...
    'clamped', [], ...
    'softev' , [], ...
    'localev', []);

engine    = dgm.infEngine;
nnodes    = dgm.nnodes;

localFacs = {}; 
if ~isempty(localEv)
    localFacs = softEvToFactors(localEvToSoftEv(dgm, localEv));
end
if ~isempty(softEv)
    localFacs = [localFacs(:); colvec(softEvToFactors(softEv))];
end
visVars   = find(clamped);
hidVars   = setdiffPMTK(1:nnodes, visVars);
G         = dgm.G;
%% Run inference
switch lower(engine)
    
    case 'jtree'
        
        if isfield(dgm, 'jtree')
            jtree          = jtreeSliceCliques(dgm.jtree, clamped);
        else
            doSlice        = true;
            factors        = cpds2Factors(dgm.CPDs, G, dgm.CPDpointers);
            factors        = addEvidenceToFactors(factors, clamped, doSlice);
            nstates        = cellfun(@(f)f.sizes(end), factors); 
            jtree          = jtreeCreate(factorGraphCreate(factors, nstates, G));
        end
        [jtree, logZlocal] = jtreeAddFactors(jtree, localFacs);
        [jtree, logZ]      = jtreeCalibrate(jtree);
        nodeBels           = jtreeQuery(jtree, num2cell(hidVars));
        logZ = logZ + logZlocal; 
        
    case 'libdaijtree'
        
        assert(isWeaklyConnected(G)); % libdai segfaults on disconnected graphs
        doSlice          = false;     % libdai often segfaults when slicing
        factors          = cpds2Factors(dgm.CPDs, G, dgm.CPDpointers);
        factors          = addEvidenceToFactors(factors, clamped, doSlice);
        [logZ, nodeBels] = libdaiJtree([factors(:); localFacs(:)]);
        
    case 'varelim'
        
        doSlice          = true;
        factors          = cpds2Factors(dgm.CPDs, G, dgm.CPDpointers);
        factors          = addEvidenceToFactors(factors, clamped, doSlice);
        factors          = multiplyInLocalFactors(factors, localFacs);
        nstates          = cellfun(@(f)f.sizes(end), factors); 
        fg               = factorGraphCreate(factors, nstates, G);
        [logZ, nodeBels] = variableElimination(fg, num2cell(hidVars));
        
    case 'enum'
        
        factors  = cpds2Factors(dgm.CPDs, G, dgm.CPDpointers);
        factors  = multiplyInLocalFactors(factors, localFacs);
        joint    = tabularFactorMultiply(factors);
        nodeBels = cell(nnodes, 1);
        for i=1:numel(hidVars)
            [nodeBels{i}, logZ] = tabularFactorCondition(joint, hidVars(i), clamped);
        end
        
    otherwise, error('%s is not a valid inference engine', dgm.infEngine);
        
end
%%
nodeBels = insertClampedBels(nodeBels, visVars, hidVars);
end