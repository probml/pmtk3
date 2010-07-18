function [bels, logZ] = dgmInferQuery(dgm, queries, varargin)
%% Compute sum_H p(Q, H | V) for each Q in queries
%
%% Inputs  
%
% dgm      - a struct as created by dgmCreate
% queries  - a query, (i.e. a list of variables) or a cell array of queries
%
%% Optional named inputs
%
% doPrune  - [false] if true, nodes conditionally independent of the query
%                    given the evidence are first removed. Note, this may
%                    not improve performance if multiple queries are
%                    requested. Not supported if logZ is also requested.
% 
% See dgmInferNodes for details on the remaining args
%
%% Outputs
%
% bels   - tabularFactors (clique beliefs) representing the queries
%
% logZ   - log of the partition sum (if this is all you want, use dgmLogprob)
%%
[clamped, softEv, localEv, doPrune] = process_options(varargin, ...
    'clamped', [], ...
    'softev' , [], ...
    'localev', [], ...
    'doPrune', false);
if doPrune && nargout > 1
    error('pruning is not supported when logZ is requested'); 
end
%%
queries              = cellwrap(queries); 
nqueries             = numel(queries);

localFacs = {}; 
softVis   = []; 
if ~isempty(localEv)
    [localFacs, softVis] = softEvToFactors(localEvToSoftEv(dgm, localEv));
end
if ~isempty(softEv)
    [lf, sv]  = softEvToFactors(softEv); 
    softVis   = unionPMTK(softVis, sv); 
    localFacs = [localFacs(:); colvec(lf(:))];
end

engine               = dgm.infEngine;
CPDs                 = dgm.CPDs;
CPDpointers          = dgm.CPDpointers;
G                    = dgm.G;
%% optionally prune conditionally independent nodes
if doPrune
    if nqueries > 1 % then call recursively 
        bels = cell(nqueries, 1);
        for q=1:nqueries
            bels{q} = dgmInferQuery(dgm, queries{q}, varargin{:});
        end
        return;
    end
    if isfield(dgm, 'jtree'), dgm = rmfield(dgm, 'jtree');  end
    query                  = queries{1}; 
    allVisVars             = [find(clamped), softVis]; % don't prune nodes with softev
    [G, pruned, remaining] = pruneNodes(G, query, allVisVars);
    CPDs                   = CPDs(CPDpointers(remaining)); 
    CPDpointers(pruned)    = []; 
    CPDpointers            = rowvec(lookupIndices(CPDpointers, remaining));
    queries                = {lookupIndices(query, remaining)}; 
    visVars                = lookupIndices(find(clamped), remaining); 
    visVals                = nonzeros(clamped); 
    clamped                = sparsevec(visVars, visVals, size(G, 1)); 
    for i=1:numel(localFacs)
       localFacs{i}.domain = lookupIndices(localFacs{i}.domain, remaining); %#ok
    end
end
%% Run inference
switch lower(engine)
    
    case 'jtree'
        
        if isfield(dgm, 'jtree') && jtreeCheckQueries(dgm.jtree, queries) 
            jtree         = jtreeSliceCliques(dgm.jtree, clamped);
            jtree         = jtreeAddFactors(jtree, localFacs);
            [jtree, logZ] = jtreeCalibrate(jtree);
            bels          = jtreeQuery(jtree, queries);
        else 
            doSlice       = true;
            factors       = cpds2Factors(CPDs, G, CPDpointers);
            factors       = addEvidenceToFactors(factors, clamped, doSlice);
            nstates       = cellfun(@(f)f.sizes(end), factors); 
            fg            = factorGraphCreate(factors, nstates, G); 
            jtree         = jtreeCreate(fg, 'cliqueConstraints', queries);
            [jtree, logZ] = jtreeCalibrate(jtree);
            bels          = jtreeQuery(jtree, queries); 
        end
            
    case 'libdaijtree'
        
        assert(isWeaklyConnected(G)); % libdai segfaults on disconnected graphs
        doSlice = false;              % libdai often segfaults when slicing
        factors = cpds2Factors(CPDs, G, CPDpointers);   
        factors = addEvidenceToFactors(factors, clamped, doSlice); 
        factors = [factors(:); localFacs(:)]; 
        [logZ, nodeBels, cliques, cliqueLookup] = libdaiJtree(factors); 
        bels    = jtreeQuery(structure(cliques, cliqueLookup), queries);
        
    case 'varelim'
        
        doSlice      = true; 
        factors      = cpds2Factors(CPDs, G, CPDpointers);   
        factors      = addEvidenceToFactors(factors, clamped, doSlice); 
        factors      = multiplyInLocalFactors(factors, localFacs);
        nstates      = cellfun(@(f)f.sizes(end), factors); 
        fg           = factorGraphCreate(factors, nstates, G);
        [logZ, bels] = variableElimination(fg, queries); 
        
    case 'enum'
        
        factors  = cpds2Factors(CPDs, G, CPDpointers);   
        factors  = multiplyInLocalFactors(factors, localFacs);
        joint    = tabularFactorMultiply(factors); 
        bels     = cell(nqueries, 1); 
        for i=1:nqueries
           [bels{i}, logZ] = tabularFactorCondition(joint, queries{i}, clamped); 
        end
        if numel(queries) == 1, bels = bels{1}; end
        
    otherwise
        error('%s is not a valid inference engine', dgm.infEngine);
end

if doPrune % shift domain back
    bels.domain = rowvec(remaining(bels.domain)); 
end

end