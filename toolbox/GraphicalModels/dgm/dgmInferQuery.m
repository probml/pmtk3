function [bels, logZ, origBels] = dgmInferQuery(dgm, queries, varargin)
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
% sliceCliques [true] if true, factors / cliques are sliced rather than
% clamped. 
% 
% See dgmInferNodes for details on the remaining args
%
%% Outputs
%
% bels   - tabularFactors (clique beliefs) representing the queries
%
% logZ   - log of the partition sum (if this is all you want, use dgmLogprob)
%
%%

% This file is from pmtk3.googlecode.com

[clamped, softEv, localEv, doPrune, doSlice] = process_options(varargin, ...
    'clamped', [], ...
    'softev' , [], ...
    'localev', [], ...
    'doPrune', false, ...
    'doSlice', true);
if doPrune && nargout > 1
    error('pruning is not supported when logZ is requested'); 
end
%%
queries              = cellwrap(queries); 
nqueries             = numel(queries);
Nnodes = size(dgm.G, 1);

if ~isempty(dgm.toporder) && ~isequal(dgm.toporder, 1:Nnodes)
  %fprintf('warning: dgmInferQueryis permuting data columns\n');
  if ~isempty(softEv), softEv = softEv(:, dgm.toporder); end
  if ~isempty(clamped), clamped = clamped(dgm.toporder); end
  if ~isempty(localEv), localEv = localEv(:, dgm.toporder); end
  origQueries = queries;
  for c=1:nqueries
    queries{c} = dgm.invtoporder(origQueries{c});
  end
end


visVars              = find(clamped); 
if ~all(cellfun(@(q)isempty(intersectPMTK(q, visVars)) , queries))
    doSlice = false; % querying observed nodes so don't slice them out of existence
end
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
engine = lower(engine); 
switch engine
    
    case 'jtree'
        
        if isfield(dgm, 'jtree') && jtreeCheckQueries(dgm.jtree, queries)
            jtree         = jtreeSliceCliques(dgm.jtree, clamped, doSlice);
        else
            factors       = cpds2Factors(CPDs, G, CPDpointers);
            factors       = addEvidenceToFactors(factors, clamped, doSlice);
            nstates       = cellfun(@(f)f.sizes(end), factors);
            cg            = cliqueGraphCreate(factors, nstates, G);
            jtree         = jtreeCreate(cg, 'cliqueConstraints', queries);
        end
        [logZ, bels] = jtreeRunInference(jtree, queries, localFacs);
            
    case 'varelim'
        
        doSlice      = true; 
        factors      = cpds2Factors(CPDs, G, CPDpointers);   
        factors      = addEvidenceToFactors(factors, clamped, doSlice); 
        factors      = multiplyInLocalFactors(factors, localFacs);
        nstates      = cellfun(@(f)f.sizes(end), factors); 
        cg           = cliqueGraphCreate(factors, nstates, G);
        [logZ, bels] = variableElimination(cg, queries); 
        
    case 'bp'
        
        doSlice      = true;
        factors      = cpds2Factors(CPDs, G, CPDpointers);
        factors      = addEvidenceToFactors(factors, clamped, doSlice);
        factors      = multiplyInLocalFactors(factors, localFacs);
        nstates      = cellfun(@(f)f.sizes(end), factors);
        cg           = cliqueGraphCreate(factors, nstates, G);
        bels         = beliefPropagation(cg, queries, dgm.infEngArgs{:});
        
        logZ = 0; % not calculated
        
    case 'enum'
        
        factors      = cpds2Factors(CPDs, G, CPDpointers);
        [logZ, bels] = bruteForceInferQuery(factors, queries, clamped, localFacs);
             
    otherwise
        
        if startswith(engine, 'libdai')
            doSlice = false;              % libdai often segfaults when slicing
            factors = cpds2Factors(CPDs, G, CPDpointers);
            factors = addEvidenceToFactors(factors, clamped, doSlice);
            factors = [factors(:); localFacs(:)];
            if isempty(dgm.infEngArgs)
                args = libdaiDefaultsGet(engine(7:end));
            else
                args = dgm.infEngArgs;
            end
            [logZ, nodeBels, cliques, cliqueLookup] = libdaiInfer(factors, args{:});
            bels = queryCliques(cliques, queries, cliqueLookup);
        else
            error('%s is not a valid inference engine', dgm.infEngine);
        end
        
end

if doPrune % shift domain back
    bels.domain = rowvec(remaining(bels.domain));
end

if ~isempty(dgm.toporder) && ~isequal(dgm.toporder, 1:Nnodes)
  % rename domain of computed queries
  origBels = bels; % for debugging
  if nqueries==1
    bels.domain = origQueries{1};
  else
    for c=1:nqueries
      bels{c}.domain = origQueries{c};
    end
  end
end

end

