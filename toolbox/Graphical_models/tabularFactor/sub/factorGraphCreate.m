function fg = factorGraphCreate(Tfac, nstates, G)
%% Construct a factor graph
%
% Tfac is a cell array of tabular factors
% nstates(j) is the number of states for node j
% G is the graph structure, (automatically infered if not specified)
% 
%%
if nargin < 3
    G  = constructGraphFromFactors(Tfac);
end
fg = structure(Tfac, nstates, G); 



% if nargin < 3 || isempty(edgeFacs)
%     fg.G = G;
%     fg.Tfac = nodeFacs;
% else
%     nfacs = numel(nodeFacs) + numel(edgeFacs);
%     if size(G, 1) == nfacs
%         fg.G = G;
%         fg.Tfac = [nodeFacs(:); edgeFacs(:)];
%         fg.isEdgePot = false(nfacs, 1); 
%     else
%         GG = zeros(nfacs, nfacs);
%         Tfac = [nodeFacs(:); edgeFacs(:)];
%         isEdgePot = false(nfacs, 1);
%         nnodeFacs = numel(nodeFacs);
%         for f=1:nfacs
%             fac = Tfac{f};
%             self = fac.domain(end);
%             if f > nnodeFacs
%                 isEdgePot(self) = true;
%             end
%             neighbors = fac.domain(1:end-1);
%             GG(self, neighbors) = 1;
%             GG(neighbors, self) = 1;
%         end
%         fg.Tfac = Tfac;
%         fg.G = GG;
%         fg.isEdgePot = isEdgePot; 
%     end  
% end
end