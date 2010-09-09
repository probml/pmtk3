function mrf2 = factorGraphToMrf2(fg, varargin)
%% Convert a factor graph to a pairwise Markov random field
% for use by Mark Schmidt's UGM library
% See mrf2Create for additional optional args
%%

% This file is from pmtk3.googlecode.com


fg = factorGraphMakePairwise(fg); % does nothing if fg is already pairwise
G = constructGraphFromFactors(fg.factors);
args = {};
maxNstates = max(fg.nstates);
nodeFacNdx = fg.nodeFacNdx;
edgeFacNdx = fg.edgeFacNdx;
%% nodePot

pots = fg.factors(nodeFacNdx);
npots = numel(pots);
nodePot = zeros(npots, maxNstates);
for i=1:npots
    T = rowvec(pots{i}.T);
    nodePot(pots{i}.domain, 1:numel(T)) = T;
end

args = [args, {'nodePot', nodePot}];

%% edgePot
E = UGM_makeEdgeStruct(G, fg.nstates); 
edgeEnds = E.edgeEnds; 
nedges   = E.nEdges;
epots    = fg.factors(edgeFacNdx);
epot     = zeros(maxNstates, maxNstates, nedges);
edgesWithPots = cell2mat(cellfuncell(@(f)f.domain, epots));
if isequal(edgesWithPots, edgeEnds)
    for i=1:nedges
        T = epots{i}.T;
        sz = size(T);
        epot(1:sz(1), 1:sz(2), i) = T;
    end
else
% if edges potentials are missing, fill them in with all ones, in the correct
% order.

    for i=1:nedges
        edge = edgeEnds(i, :); 
        ndx = find(edge(1)==edgesWithPots(:, 1) & edge(2)==edgesWithPots(:, 2), 1, 'first');
        if isempty(ndx)
           epot(:, :, i) = 1;  
        else
           T = epots{ndx}.T;
           sz = size(T);
           epot(1:sz(1), 1:sz(2), i) = T;
        end
    end
end

args = [args, {'edgePot', epot}];
mrf2 = mrf2Create(G, fg.nstates, args{:}, 'tied', 0, varargin{:});
end
