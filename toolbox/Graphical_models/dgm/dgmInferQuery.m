function [logZ, bels] = dgmInferQuery(dgm, queries, varargin)
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
%                    requested. 
% 
% See dgmInferNodes for details on the remaining args
%
%% Outputs
%
% logZ   - log normalization constant 
%
% bels   - tabularFactors (clique beliefs) representing the queries
%%
[clamped, softev, localev, doPrune] = process_options(varargin, ...
    'clamped', [], ...
    'softev' , [], ...
    'localev', [], ...
    'doPrune', false);
%%
engine               = dgm.infEngine;
[localFacs, softVis] = dgmEv2LocalFacs(dgm, localev, softev);
G                    = dgm.G;
queries              = cellwrap(queries); 
nqueries             = numel(queries);
if doPrune
    error('pruning is not yet implemented'); 
    allVisVars = [find(clamped), softVis];
    if isfield(dgm, 'jtree')
       dgm = rmfield(dgm, 'jtree'); 
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
            factors       = cpds2Factors(dgm.CPDs, G, dgm.CPDpointers);
            factors       = addEvidenceToFactors(factors, clamped, doSlice);
            fg            = factorGraphCreate(factors, G); 
            jtree         = jtreeInit(fg, 'cliqueConstraints', queries);
            [jtree, logZ] = jtreeCalibrate(jtree);
            bels          = jtreeQuery(jtree, queries); 
        end
            
    case 'libdaijtree'
        
        assert(isWeaklyConnected(dgm.G)); % libdai segfaults on disconnected graphs
        doSlice = false;                  % libdai often segfaults when slicing
        factors = cpds2Factors(CPDs, G, dgm.CPDpointers);   
        factors = addEvidenceToFactors(factors, clamped, doSlice); 
        factors = [factors(:); localFacs(:)]; 
        factors = cellfuncell(@tabularFactorNormalize, factors); 
        [logZ, nodeBels, cliques, cliqueLookup] = libdaiJtree(factors); 
        bels    = jtreeQuery(structure(cliques, cliqueLookup), queries);
        
    case 'varelim'
        
        doSlice      = true; 
        factors      = cpds2Factors(dgm.CPDs, G, dgm.CPDpointers);   
        factors      = addEvidenceToFactors(factors, clamped, doSlice); 
        factors      = multiplyInLocalFactors(factors, localFacs);
        fg           = factorGraphCreate(factors, G);
        [logZ, bels] = variableElimination(fg, queries); 
        
    case 'enum'
        
        factors  = cpds2Factors(dgm.CPDs, G, dgm.CPDpointers);   
        factors  = multiplyInLocalFactors(factors, localFacs);
        joint    = tabularFactorMultiply(factors); 
        bels     = cell(nqueries, 1); 
        for i=1:nqueries
           [bels{i}, logZ] = tabularFactorCondition(joint, queries{i}, clamped); 
        end
        
    otherwise
        error('%s is not a valid inference engine', dgm.infEngine);
end

if doPrune % shift domain back
    
end

end