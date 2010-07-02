function [postQuery, Z, jtree] = junctionTree(model, queryVars, evidence, jtree)
%% Junction tree algorithm for computing sum_H p(Q, H | V=v)
%
%% Inputs
%
% model     - a struct with fields Tfac and G: Tfac is a cell array of
%             tabularFactors, and G is the graph structure, an adjacency
%             matrix.
%
% queryVars - the query variables
%
% evidence  - a sparse vector of length nvars indicating the values for the
%             observed variables with 0 elsewhere.
%
% jtree     - an optional struct as created by this function to allow for
%             multiple queries efficiently. If jtree is specified, evidence
%             must be [], i.e. we don't recalibrate based on new evidence.
%% Outputs
% postQuery - a TabularFactor
% Z         - the normalization constant
% jtree     - the junction tree struct, pass it back into junctionTree
%             if you have multiple queries.
%%
% See also variableElimination, tabularFactorCondition
%%
if nargin == 0; % test to be removed
    test();
    return;
end

if nargin < 4 || ~isempty(evidence) % build the jtree
    factors  = model.Tfac(:);
    nfactors = numel(factors);
    
    if nargin > 2 && ~isempty(evidence) && nnz(evidence) > 0
        %% Condition on the evidence
        visVars  = find(evidence);
        visVals  = nonzeros(evidence);
        for i=1:numel(factors)
            localVars = intersectPMTK(factors{i}.domain, visVars);
            if isempty(localVars),  continue;  end
            localVals  = visVals(lookupIndices(localVars, visVars));
            factors{i} = tabularFactorSlice(factors{i}, localVars, localVals);
        end
    end
    %% Setup clique tree
    nstates     = cellfun(@(t)t.sizes(end), factors);
    factorGraph = moralizeGraph(model.G);
    tmpGraph    = factorGraph;
    for f=1:nfactors
        dom = factors{f}.domain;
        tmpGraph(dom, dom) = 1;
    end
    tmpGraph      = mkSymmetric(setdiag(tmpGraph, 0));
    elimOrder     = minweightElimOrder(tmpGraph);
    tmpGraph      = mkChordal(tmpGraph, elimOrder);
    perfectOrder  = perfectElimOrder(tmpGraph);
    cliqueIndices = chordal2RipCliques(tmpGraph, perfectOrder);
    cliqueGraph   = ripCliques2Jtree(cliqueIndices);
    ncliques      = numel(cliqueIndices);
    ftmp          = [factors{:}];
    nvars         = max([ftmp.domain]);
    cliqueLookup  = false(nvars, ncliques);
    for c=1:ncliques
        cliqueLookup(cliqueIndices{c}, c) = true;
    end
    %% add factors to cliques
    factorLookup = false(nfactors, ncliques);
    for f=1:nfactors
        candidateCliques = find(all(cliqueLookup(factors{f}.domain, :), 1));
        smallest = minidx(cellfun(@(x)numel(x), cliqueIndices(candidateCliques)));
        factorLookup(f, candidateCliques(smallest)) = true;
    end
    cliques = cell(ncliques, 1);
    for c=1:ncliques
        ndx        = cliqueIndices{c};
        T          = tabularFactorCreate(onesPMTK(nstates(ndx)), ndx);
        tf         = [{T}; factors(factorLookup(:, c))];
        cliques{c} = tabularFactorMultiply(tf);
    end
    %% Construct separating sets
    % for each edge in the clique tree, construct the separating set.
    sepsets  = cell(ncliques);
    [is, js] = find(cliqueGraph);
    for k=1:numel(is)
        i = is(k);
        j = js(k);
        sepsets{i, j} = intersectPMTK(cliques{i}.domain, cliques{j}.domain);
        sepsets{j, i} = sepsets{i, j};
    end
    %% Calibrate
    cliqueTree          = triu(cliqueGraph);
    messages            = cell(ncliques, ncliques);
    allexcept           = @(x)[1:x-1,(x+1):ncliques];
    root                = find(not(sum(cliqueTree, 1)), 1);
    readyToSend         = false(1, ncliques);
    leaves              = not(sum(cliqueTree, 2));
    readyToSend(leaves) = true;
    %% upwards pass
    while not(readyToSend(root))
        current = find(readyToSend, 1);
        parent  = parents(cliqueTree, current);
        m       = [cliques(current); messages(allexcept(parent), current)];
        psi     = tabularFactorMultiply(removeEmpty(m));
        message = tabularFactorMarginalize(psi, sepsets{current, parent});
        messages{current, parent} = message;
        readyToSend(current) = false;
        childMessages        = messages(children(cliqueTree, parent), parent);
        readyToSend(parent)  = all(cellfun(@(x)~isempty(x), childMessages));
    end
    %% downwards pass
    while(any(readyToSend))
        current = find(readyToSend, 1);
        C = children(cliqueTree, current);
        for i=1:numel(C)
            child   = C(i);
            m       = [cliques(current); messages(allexcept(child), current)];
            psi     = tabularFactorMultiply(removeEmpty(m));
            message = tabularFactorMarginalize(psi, sepsets{current, child});
            messages{current, child} = message;
            readyToSend(child) = true;
        end
        readyToSend(current) = false;
    end
    %% update the cliques with all of the messages sent to them
    for c=1:ncliques
        m          = removeEmpty([cliques(c); messages(:, c)]);
        cliques{c} = tabularFactorMultiply(m);
    end
    jtree = structure(cliques, cliqueGraph, cliqueLookup);
end

%% Find a clique to answer query
cliques      = jtree.cliques;
cliqueLookup = jtree.cliqueLookup;
candidates   = find(all(cliqueLookup(queryVars, :), 1));
if ~isempty(candidates)
    cliqueNdx = candidates(minidx(cellfun(@(x)numel(x), cliques(candidates))));
    tf        = tabularFactorMarginalize(cliques{cliqueNdx}, queryVars);
else
    fprintf('performing an out of clique query\n'); 
    clqScopes = [cellfuncell(@(c)c.domain, cliques); num2cell(1:nvars)']; 
    ndx = greedySpan(queryVars, clqScopes); 
    assert(~isempty(ndx)); 
    beliefs = cell(1, numel(ndx)); 
    for i=1:numel(ndx)
        beliefs{i} = junctionTree(model, clqScopes{ndx(i)}, [], jtree); 
    end
    tf = tabularFactorMultiply(beliefs); 
end
[postQuery, Z] = tabularFactorNormalize(tf);
end







function test()
%% To be removed
alarm = loadData('alarmNetwork');
CPT = alarm.CPT;
G   = alarm.G;
n   = numel(CPT);
Tfac = cell(n, 1);
for i=1:numel(CPT)
    family = [parents(G, i), i];
    Tfac{i} = tabularFactorCreate(CPT{i}, family);
end
model = structure(Tfac, G);
evidence = sparsevec([11 15], [2 4], n);
tic; ve = variableElimination(model, [2:10, 12:13], evidence); toc
tic; jt = junctionTree(model,[2:10, 12:13] , evidence); toc

assert(approxeq(ve.T, jt.T));

end

