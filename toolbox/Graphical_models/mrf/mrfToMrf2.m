function mrf2 = mrfToMrf2(mrf, varargin)
%% Convert a PMTK mrf to Mark Schmidt's mrf2 format
% Edge potentials, (if any) must all be pairwise

nstates    = mrf.nstates;
args = {};
nodePots = mrf.nodePots(mrf.nodePotPointers);
if ~isempty(nodePots)
    
    maxNstates = max(nstates);
    pot = zeros(mrf.nnodes, maxNstates);
    for i=1:numel(nodePots)
        pot(i, :) = rowvec(nodePots{i}.T);
    end
    args = [args, {'nodePot', pot}];
end


edgePots = mrf.edgePots(mrf.edgePotPointers);
if ~isempty(edgePots)
    edgePot = zeros(maxNstates, maxNstates, nedges(mrf.G));
    for j=1:numel(edgePots)
        E = edgePot(:, :, j);
        T = edgePots{j}.T(:);
        E(1:numel(T)) = T;
        edgePot(:, :, j) = E;
    end
    args = [args, {'edgePot', edgePot}];
end
mrf2 = mrf2Create(mrf.G, nstates, args{:}, varargin{:}); 
end