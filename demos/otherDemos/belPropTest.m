%% Test that belief propagation gives exact results on a tree
setSeed(0); 
K = 2; 
depth = 3; 
nvars = ((K.^depth)-1)/(K-1);
nstates = 2; 
dgm = mkRndTreeDgm(K, depth, nstates); 
%drawNetwork(dgm.G);
nodeBelsJT = dgmInferNodes(dgm); 
%%


cliques = beliefPropagation(dgm.factors);
cliqueLookup = createFactorLookupTable(cliques); 
nodeBelsBP = jtreeQuery(structure(cliques, cliqueLookup), num2cell(1:nvars)); 

for i=1:nvars
   [nodeBelsJT{i}.T(:) , nodeBelsBP{i}.T(:)]
end


assert(tfequal(nodeBelsJT, nodeBelsBP));