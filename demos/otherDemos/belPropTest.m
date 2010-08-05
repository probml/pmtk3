%% Test that belief propagation gives exact results on a tree
%setSeed(0); 
K = 3; 
depth = 5; 
nvars = ((K.^depth)-1)/(K-1);
nstates = 2; 
dgm = mkRndTreeDgm(K, depth, nstates); 
%drawNetwork(dgm.G);
tic
nodeBelsJT = dgmInferNodes(dgm); 
toc
%%


tic

cliques = beliefPropagation(cliqueGraphCreate(dgm.factors, dgm.nstates, dgm.G));
cliqueLookup = createFactorLookupTable(cliques); 
nodeBelsBP = jtreeQuery(structure(cliques, cliqueLookup), num2cell(1:nvars)); 
toc
% for i=1:nvars
%    [nodeBelsJT{i}.T(:) , nodeBelsBP{i}.T(:)]
% end


assert(tfequal(nodeBelsJT, nodeBelsBP));
