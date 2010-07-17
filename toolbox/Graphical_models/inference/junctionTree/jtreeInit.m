function jtree = jtreeInit(fg, varargin)
%% Initialize a junction tree for a given factor graph
% This structure can then be passed to jtreeCalibrate
% Optionally include cliqueConstraints, a cell array of sets of variable
% indices if you want to guarantee that cliques containing these sets are
% created.
%% setup
cc       = process_options(varargin, 'cliqueConstraints', {}); 
factors  = fg.Tfac(:);
nfactors = numel(factors);
nstates  = cellfun(@(t)t.sizes(end), factors);
G        = moralizeGraph(fg.G);
nvars    = size(G, 1);
%% add in clique constraints
cc = cellwrap(cc); 
for i=1:numel(cc)
    c = cc{i};
    G(c, c) = 1;
end
G = setdiag(G, 0);
%% build clique tree
% clqs{i} is the i'th maximal clique, ordered by RIP
elimOrder                   = minweightElimOrder(G, nstates);
G                           = mkChordal(G, elimOrder);
[pElimOrder, chordal, clqs] = maxCardinalitySearch(G); 
cliqueTreeUndir             = mcsCliques2Jtree(clqs);
%% create clique lookup table
% cliqueLookup(i, c) = true if GM node i is in clqs{c}
ncliques = numel(clqs);
cliqueLookup = false(nvars, ncliques);                 
for c=1:ncliques
    cliqueLookup(clqs{c}, c) = true;
end
%% add factors to cliques
initClqSizes = cellfun('length', clqs);
factorLookup = false(nfactors, ncliques);
for f=1:nfactors
    candidateCliques = find(all(cliqueLookup(factors{f}.domain, :), 1));
    smallest         = minidx(initClqSizes(candidateCliques));
    factorLookup(f, candidateCliques(smallest)) = true;
end
cliques = cell(ncliques, 1); % tabular potentials
for c=1:ncliques
    ndx        = clqs{c};
    T          = tabularFactorCreate(onesPMTK(nstates(ndx)), ndx);
    tf         = [{T}; factors(factorLookup(:, c))];
    cliques{c} = tabularFactorMultiply(tf);
end
%% determine message schedule
root                        = nvars; % last one
rootCliques                 = find(cliqueLookup(root, :));
rootClqNdx                  = rootCliques(minidx(initClqSizes(rootCliques)));
[preOrder, postOrder, pred] = dfsearch(cliqueTreeUndir, rootClqNdx, false);
% Make a directed version of cliqueTreeUndir
cliqueTree = zeros(ncliques, ncliques);
for i=1:length(pred)
    if pred(i) > 0
        cliqueTree(pred(i), i) = 1;
    end
end
postOrderParents = cell(1, length(postOrder));
for i = postOrder
    postOrderParents{i} = parents(cliqueTree, i);
end
preOrderChildren = cell(1, length(preOrder));
for i = preOrder
    preOrderChildren{i} = children(cliqueTree, i);
end
%% package 
jtree = structure(cliques, preOrder, postOrder, ...
    preOrderChildren, postOrderParents, cliqueLookup, cliqueTree);
end