function [logZ, bels] = dgmInferQuery(dgm, queries, varargin)
%% Compute sum_H p(Q, H | V) for each Q in queries

[clamped, softev, localev, doPrune] = process_options(varargin, ...
    'clamped', [], ...
    'softev' , [], ...
    'localev', [], ...
    'doPrune', false);

engine    = dgm.infEngine;
[localFacs, softVis] = dgmEv2LocalFacs(dgm, localev, softev);
allVisVars = [find(clamped), softVis];
G = dgm.G;
nqueries = numel(queries);
%% Run inference
switch lower(engine)
    case 'jtree'
        if isfield(dgm, 'jtree') && jtreeCheckQueries(dgm.jtree, queries) && ~doPrune
            jtree = jtreeSliceCliques(dgm.jtree, clamped);
            jtree = jtreeAddFactors(jtree, localFacs);
            jtree = jtreeCalibrate(jtree);
            [logZ, bels] = jtreeQuery(jtree, queries);
        else 
            doSlice = true;
            factors = addEvidenceToFactors(dgm.factors, clamped, doSlice);
            if ~doPrune
                jtree   = jtreeInit(factorGraphCreate(factors, G), 'cliqueConstraints', queries);
                jtree   = jtreeCalibrate(jtree);
                [logZ, bels] = jtreeQuery(jtree, queries);
            else
                bels = cell(nqueries, 1);
                for q=1:nqueries
                    query = queries{q}; 
                    [Gp, pruned, remaining] = pruneNodes(G, query, allVisVars); 
                    facp = factors; 
                    facp(pruned) = []; 
                    for f=1:numel(facp)
                       facp.domain = lookupIndices(facp.domain, remaining);
                    end
                    qq = lookupIndices(query, remaining); 
                    jtree = jtreeInit(factorGraphCreate(facp, ...
                        Gp), 'cliqueConstraints', qq);
                    jtree = jtreeCalibrate(jtree);
                    [logZ, bel] = jtreeQuery(jtree, qq);
                    bel.domain = remaining(bel.domain); 
                    bels{q} = bel; 
                end
            end
        end
    case 'libdaijtree'
        assert(isWeaklyConnected(dgm.G)); % libdai segfaults on disconnected graphs
        doSlice = false;                  % libdai often segfaults when slicing
        factors          = addEvidenceToFactors(dgm.factors, clamped, doSlice); 
        factors          = [factors(:); localFacs(:)]; 
        factors          = cellfuncell(@tabularFactorNormalize, factors); 
        [logZ, nodeBels, cliques, cliqueLookup] = libdaiJtree(factors); 
        [logZ, bels] = jtreeQuery(structure(cliques, cliqueLookup), queries);
    case 'varelim'
        doSlice = true; 
        factors = addEvidenceToFactors(dgm.factors, clamped, doSlice); 
        if ~isempty(localFacs)
            factors = cellfuncell(@tabularFactorMultiply, factors, localFacs); 
            factors = cellfuncell(@tabularFactorNormalize, factors); 
        end
        bels = cell(nhid, 1); 
        if ~doPrune
            for i = 1:nqueries
               [logZ, bels{i}] = ...
                   variableElimination(factorGraphCreate(factors, dgm.G), queries{i});  
            end
        else
           for i = 1:nqueries
               
               
               [logZ, bels{i}] = ...
                   variableElimination(factorGraphCreate(factors, dgm.G), queries{i});  
            end
            
        end
    case 'enum'
        factors = dgm.factors; 
        if ~isempty(localFacs)
            factors = cellfuncell(@tabularFactorMultiply, factors, localFacs); 
            factors = cellfuncell(@tabularFactorNormalize, factors); 
        end        
        joint = (tabularFactorMultiply(factors)); 
        visVars = find(clamped); 
        visVals = nonzeros(clamped); 
        bels = cell(nqueries, 1);
        logZ = zeros(nqueries, 1); 
        for i=1:nqueries
           [bels{i}, logZ] = tabularFactorCondition(joint, queries{i}, visVars, visVals); 
        end
    otherwise
        error('%s is not a valid inference engine', dgm.infEngine);
end
end