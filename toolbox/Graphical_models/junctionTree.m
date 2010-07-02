function [postQuery, Z, jtree] = junctionTree(model, queryVars, evidence, jtree)
%% Junction tree algorithm for computing sum_H p(Q, H | V=v)
%
%% Inputs
%
% model     - a struct with fields Tfac and G: Tfac is a cell array of
%             tabularFactors, and G is the variable graph structure: an 
%             adjacency matrix.
%
% queryVars - the query variables
%
% evidence  - a sparse vector of length nvars indicating the values for the
%             observed variables with 0 elsewhere.
%
% jtree     - an optional struct as created by this function to allow for
%             multiple queries efficiently. If jtree is specified, evidence
%             must be [], i.e. we don't recalibrate based on new evidence. 
%             Further, out-of-clique subsequent queries are not supported. 
%% Outputs
% postQuery - a TabularFactor
% Z         - the normalization constant
% jtree     - the junction tree struct, pass it back into junctionTree
%             if you have multiple queries. 
%%
% See also variableElimination, tabularFactorCondition
%%
if nargin == 0;  test(); return; end % test to be removed
%%
if nargin < 4  % build the jtree
    factors  = model.Tfac(:);
    nfactors = numel(factors);
    if nargin > 2 && ~isempty(evidence) && nnz(evidence) > 0
        %% condition on the evidence
        visVars  = find(evidence);
        overlap = intersectPMTK(visVars, queryVars);
        if ~isempty(overlap)
            error('these query nodes are already observed: %d', overlap);
        end
        visVals  = nonzeros(evidence);
        for i=1:numel(factors)
            localVars = intersectPMTK(factors{i}.domain, visVars);
            if isempty(localVars),  continue;  end
            localVals  = visVals(lookupIndices(localVars, visVars));
            factors{i} = tabularFactorSlice(factors{i}, localVars, localVals);
        end
    end
    %% setup jtree
    qv            = queryVars;
    nstates       = cellfun(@(t)t.sizes(end), factors);
    G             = moralizeGraph(model.G);
    nvars         = size(G, 1);
    G(qv, qv)     = 1;  % ensure a clique will be built among the query vars
    G             = setdiag(G, 0);
    G             = mkChordal(G, minweightElimOrder(G, nstates));
    cliqueIndices = chordal2RipCliques(G, perfectElimOrder(G));
    cliqueGraph   = ripCliques2Jtree(cliqueIndices);
    ncliques      = numel(cliqueIndices);
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
    %% construct separating sets
    sepsets  = cell(ncliques);
    [is, js] = find(cliqueGraph);
    for k=1:numel(is)
        i = is(k);
        j = js(k);
        sepsets{i, j} = intersectPMTK(cliques{i}.domain, cliques{j}.domain);
        sepsets{j, i} = sepsets{i, j};
    end
    %% calibrate
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
%% find a clique to answer query
cliques      = jtree.cliques;
cliqueLookup = jtree.cliqueLookup;
candidates   = find(all(cliqueLookup(queryVars, :), 1));
if isempty(candidates)
    error('out of clique queries are not supported'); % only happens if reusing an existing jtree
end
cliqueNdx  = candidates(minidx(cellfun(@(x)numel(x), cliques(candidates))));
tf = tabularFactorMarginalize(cliques{cliqueNdx}, queryVars);
[postQuery, Z] = tabularFactorNormalize(tf);
end







function test()
%% to be removed
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
evidence = sparsevec([11 12 29 30], [2 1 1 2], n);
queryVars = [1 2 9 22 33:37];
%evidence = sparsevec([12 13], [2 2], n);
%queryVars = 9;
tic; ve = variableElimination(model, queryVars, evidence); toc
tic; [jt, Z, jtree] = junctionTree(model, queryVars , evidence); toc

assert(approxeq(ve.T, jt.T));

end

