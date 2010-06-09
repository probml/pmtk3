function [logPot] = UGM_LogConfigurationPotential(y,nodePot,edgePot,edgeEnds)
% [logPot] = UGM_LogConfigurationPotential(y,nodePot,edgePot,edgeEnds)
nNodes = size(nodePot,1);
nEdges = size(edgeEnds,1);

logPot = 0;

% Nodes
for n = 1:nNodes
   logPot = logPot+log(nodePot(n,y(n)));
end

% Edges
for e = 1:nEdges
   n1 = edgeEnds(e,1);
   n2 = edgeEnds(e,2);
   logPot = logPot+log(edgePot(y(n1),y(n2),e));
end