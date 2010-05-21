function [nodeBel] = MeanFieldGibbsFreeEnergyProject(nodeBel,nNodes,nStates)

nodeBel = reshape(nodeBel,nNodes,nStates);
for n = 1:nNodes
   nodeBel(n,:) = projectSimplex(nodeBel(n,:));
end
nodeBel = nodeBel(:);