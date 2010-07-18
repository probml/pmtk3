function fg = factorGraphCreate(G, nodeFacs, edgeFacs)
%% Construct a factor graph
%
% fg = factorGraphCreate(G, Tfac)
%
% OR
%
% fg = factorGraphCreate(G, nodeFacs, edgeFacs)
%
% In the first case, G is the adjacency matrix for the whole factor graph
% and we do not distinguish between node and edge factors. 
%
% In the second case, if size(G, 1) == numel(nodeFacs), G is assumed to
% be the adjacency matrix for nodeFacs only, and fg.G is then expanded to
% represent all of the factors, (i.e to represent edge potentials
% explicitly as nodes in the graph). 
%%
if nargin < 3 || isempty(edgeFacs)
    fg.G = G;
    fg.Tfac = nodeFacs;
else
    nfacs = numel(nodeFacs) + numel(edgeFacs);
    if size(G, 1) == nfacs
        fg.G = G;
        fg.Tfac = [nodeFacs(:); edgeFacs(:)];
        fg.isEdgePot = false(nfacs, 1); 
    else
        GG = zeros(nfacs, nfacs);
        Tfac = [nodeFacs(:); edgeFacs(:)];
        isEdgePot = false(nfacs, 1);
        nnodeFacs = numel(nodeFacs);
        for f=1:nfacs
            fac = Tfac{f};
            self = fac.domain(end);
            if f > nnodeFacs
                isEdgePot(self) = true;
            end
            neighbors = fac.domain(1:end-1);
            GG(self, neighbors) = 1;
            GG(neighbors, self) = 1;
        end
        fg.Tfac = Tfac;
        fg.G = GG;
        fg.isEdgePot = isEdgePot; 
    end  
end
end