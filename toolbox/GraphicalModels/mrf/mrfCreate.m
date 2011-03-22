function mrf = mrfCreate(G, varargin)
%% Create a markov random field
% G is undirected graph, (an adjacency matrix) representing the node
% topology. Currently the interface only accepts potentials
% on nodes and edges, however support for general
% clique potentials may be added later.
%% Named Inputs
%
% 'nodePots'           - a cell array of either tabularFactors or numeric
%                        matrices representing the node potentials. Use
%                        numeric matrices when parameter tying.
%                        Use must specify at least one nodePots 
%                        since this implicitly defines the nstates
%
% 'edgePots'            - a cell array of either tabularFactors or numeric
%                        matrices representing the edge potentials. If numeric
%                        matrices are passed in, we assume these are all
%                        pairwise. Use numeric matrices when parameter
%                        tying the edges, (which is only supported in the
%                        pairwise case). If you specify numeric matrices,
%                        list them according to the linear indexing of G,
%                        i.e. so that the kth edge is the one
%                        between nodes i and j in this code:
%                        edges = find(tril(G));
%                        [i, j] = ind2sub(size(G), edges(k))
%
% 'localCPDs'          - a cell array of local conditional probability
%                        distributions (structs), which 'hang' off of the
%                        nodes to handle (usually continuous) observations.
%                        See condGaussCpd, tabularCpd, noisyOrCpd
%
% 'nodePotPointers'     - if specified, nodePots{nodePotPointers(j)} is used
%                        as the potential for node j.
%
% 'edgePotPointers'     - if specified, edgePots{edgePotPointers(e)} is used
%                        as the potential for edge e, (see edge ordering
%                        note under edgePots above).
%
% 'localCPDpointers'    - if specified, localCPDs{localCPDpointers(j)} is
%                        used as the localCPD whose parent is node j.
%
% 'infEngine'          - an inference engine, one of the following: 
%                     {['jtree'], 'varelim', 'bp', 'enum', 'libdai*'}
%
%                     libdai* - replace * with any valid libdai inference
%                     method or alias. Type 'help libdaiOptions' file for
%                     a full list. If you want to specify non-default
%                     config values, set them using
%                     'infEngArgs', {'*', '[name1=val1, name2=val2, ...]'}
%
%
% 'infEngArgs'          - optional inf engine specific args - a cell array
%
% 'precomputeJtree'     - [true] set to false if you don't want to precompute
%                        the jtree.
%
%%

% This file is from pmtk3.googlecode.com

[nodePots, edgePots, localCPDs, ...
    nodePotPointers, edgePotPointers, localCPDpointers, ...
    infEngine, infEngArgs, precomputeJtree] =    ...
    process_options(varargin       , ...
    'nodePots'           , []      , ...
    'edgePots'           , []      , ...
    'localCPDs'          , []      , ...
    'nodePotPointers'    , []      , ...
    'edgePotPointers'    , []      , ...
    'localCPDpointers'   , []      , ...
    'infEngine'          , 'jtree' , ...
    'infEngArgs'         , {}      , ...
    'precomputeJtree'    , true);

nodePots  = cellwrap(nodePots);
edgePots  = cellwrap(edgePots);
localCPDs = cellwrap(localCPDs);
nnodes    = size(G, 1);
G = mkSymmetric(G);

%% set default values
if isempty(nodePotPointers)
    if numel(nodePots) == 1
        nodePotPointers = ones(1, nnodes);
    else
        nodePotPointers = 1:nnodes;
    end
end
if isempty(edgePotPointers)
    if numel(edgePots) == 1
        edgePotPointers = ones(1, nedges(G, false));
    else
        edgePotPointers = 1:nedges(G, false);
    end
end
if isempty(localCPDpointers)
    if numel(localCPDs) == 1
        localCPDpointers = ones(1, nnodes);
    else
        localCPDpointers = 1:nnodes;
    end
end

% we convert potentials (fixed number of them)
% to factors (one per node/ edge)

%% convert any numeric matrices to tabular factors
if ~isempty(nodePots);
    nodeFactors = nodePots(nodePotPointers);
    for f=1:numel(nodeFactors)
        if isnumeric(nodeFactors{f})
            nodeFactors{f} = tabularFactorCreate(nodeFactors{f},  f);
        end
    end
end
nstates = cellfun(@(f)f.sizes(end), nodeFactors); 
if ~isempty(edgePots)
    E = find(tril(G));
    sz = size(G);
    edgeFactors = edgePots(edgePotPointers);
    for e=1:numel(edgeFactors)
        fac = edgeFactors{e};
        if isnumeric(fac) && ~isempty(fac)
            [i, j] = ind2sub(sz, E(e));
            edgeFactors{e} = tabularFactorCreate(fac, [j i]);
        end
    end
    edgeFactors = removeEmpty(edgeFactors);
else
  edgeFactors = {};
end

%% save edge information
nEdgeFacs   = numel(edgeFactors); 
edges       = cell(nEdgeFacs, 1); 
edgeLookup  = false(nnodes, nEdgeFacs);
for i=1:numel(edgeFactors)
   dom      =  edgeFactors{i}.domain;  
   edges{i} = dom; 
   edgeLookup(dom, i) = true; 
end
%% combine node and edge factors into a cliqueGraph

% KPM 27Sep10: modified to handle possibly disconnected nodes
cliqueGraph = cliqueGraphCreate([rowvec(nodeFactors) rowvec(edgeFactors)], nstates);
%{
if isempty(edgeFactors)
   cliqueGraph = cliqueGraphCreate(nodeFactors, nstates, G);  
else
    factors = edgeFactors;  
    for f=1:nnodes
        ndx = find(edgeLookup(f, :), 1);
        factors{ndx} = tabularFactorMultiply(factors{ndx}, nodeFactors{f}); 
    end
    cliqueGraph = cliqueGraphCreate(factors, nstates);  
end
%}

%% package
mrf = structure(G, cliqueGraph, localCPDs, localCPDpointers, ...
    localCPDpointers, infEngine, nnodes, edges, nstates, ...
    nodePots, nodePotPointers, edgePots, edgePotPointers, infEngArgs, ...
    nodeFactors, edgeFactors); 

mrf.isdirected = false;
mrf.modelType = 'mrf';
%% precompute jtree
if strcmpi(infEngine, 'jtree') && precomputeJtree
    mrf.jtree = jtreeCreate(cliqueGraph);
end
end
