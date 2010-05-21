function [pot] = UGM_ConfigurationPotential(y,nodePot,edgePot,edgeEnds)
% [pot] = UGM_ConfigurationPotential(y,nodePot,edgePot,edgeEnds)
nNodes = size(nodePot,1);
nEdges = size(edgeEnds,1);

pot = 1;

% Nodes
for n = 1:nNodes
   pot = pot*nodePot(n,y(n));
end

% Edges
for e = 1:nEdges
   n1 = edgeEnds(e,1);
   n2 = edgeEnds(e,2);
   pot = pot*edgePot(y(n1),y(n2),e);
end