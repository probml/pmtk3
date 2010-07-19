function [nodeBels, logZ, edgeBels] = mrfInferNodes(mrf, varargin)
%% Return all node beliefs (single marginals)
% 
% mrf is a struct as created by mrfCreate
%
% Optional named args are the same as for dgmInferNodes
%%
[clamped, softEv, localEv] = process_options(varargin, ...
    'clamped', [], ... % nodes only
    'softev' , [], ...
    'localev', []);

engine = mrf.infEngine;
nnodes = mrf.nnodes;
fg     = mrf.factorGraph; 

localFacs = {}; 
if ~isempty(localEv)
    localFacs = softEvToFactors(localEvToSoftEv(mrf, localEv));
end
if ~isempty(softEv)
    localFacs = [localFacs(:); colvec(softEvToFactors(softEv))];
end
visNodes = find(clamped);
hidNodes = setdiffPMTK(1:nnodes, visNodes);

%% Run inference
switch lower(engine)
    
    case 'jtree'
        
        if isfield(mrf, 'jtree')
            jtree     = jtreeSliceCliques(mrf.jtree, clamped);
        else
            doSlice   = true;
            fg.Tfac   = addEvidenceToFactors(fg.Tfac, clamped, doSlice);
            fg.nstates(visNodes) = 1; 
            jtree     = jtreeCreate(fg);
        end
        jtree         = jtreeAddFactors(jtree, localFacs);
        [jtree, logZ] = jtreeCalibrate(jtree);
        nodeBels      = jtreeQuery(jtree, num2cell(hidNodes));
        if nargout > 2
            edgeBels  = jtreeQuery(jtree, mrf.edges);
        end
        
    case 'libdaijtree'
        
        assert(isWeaklyConnected(fg.G)); % libdai segfaults on disconnected graphs
        doSlice = false;     % libdai often segfaults when slicing
        factors = addEvidenceToFactors(fg.Tfac, clamped, doSlice);
        factors = [factors(:); localFacs(:)];
        [logZ, nodeBels, cliques, cliqueLookup] = libdaiJtree(factors);
        if nargout > 2
            edgeBels  = jtreeQuery(structure(cliques, cliqueLookup), mrf.edges);
        end
        
    case 'varelim'
        
        doSlice          = true;
        factors          = addEvidenceToFactors(fg.Tfac, clamped, doSlice);
        factors          = multiplyInLocalFactors(factors, localFacs);
        fg.Tfac          = factors; 
        [logZ, nodeBels] = variableElimination(fg, num2cell(hidNodes));
        if nargout > 2
          
           error('not yet implemented'); 
        end
        
    case 'enum'

        factors  = multiplyInLocalFactors(fg.Tfac, localFacs);
        joint    = tabularFactorMultiply(factors);
        nodeBels = cell(nnodes, 1);
        for i=1:numel(hidVars)
            [nodeBels{i}, logZ] = tabularFactorCondition(joint, hidVars(i), clamped);
        end
        if nargout > 2
           error('not yet implemented'); 
        end
        
    otherwise, error('%s is not a valid inference engine', mrf.infEngine);
        
end
nodeBels = insertClampedBels(nodeBels, visNodes, hidNodes);
end