%% Test that belief propagation gives exact results on a tree
%setSeed(0); 
K = 3; 
depth = 5; 
nvars = ((K.^depth)-1)/(K-1);
nstates = 2; 

dgm = mkRndTreeDgm(K, depth, nstates); 
%drawNetwork(dgm.G);
dgm = rmfield(dgm, 'jtree'); % get a better timing comparison
tic
[nodeBelsJT] = dgmInferNodes(dgm); 
toc
%%

factors = cpds2Factors(dgm.CPDs, dgm.G, dgm.CPDpointers); 

tic
nodeBelsBP = beliefPropagation(cliqueGraphCreate(factors, dgm.nstates, dgm.G), ...
    num2cell(1:nvars));

toc
% for i=1:nvars
%    [nodeBelsJT{i}.T(:) , nodeBelsBP{i}.T(:)]
% end


assert(tfequal(nodeBelsJT, nodeBelsBP));
