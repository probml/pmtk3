%% Test that belief propagation gives exact results on a tree
%setSeed(0); 
K = 3; 
depth = 4; 
nvars = ((K.^depth)-1)/(K-1);
nstates = 2; 

dgm = mkRndTreeDgm(K, depth, nstates); 
%drawNetwork(dgm.G);
[nodeBelsJT] = dgmInferNodes(dgm); 
%%
dgm.infEngine = 'bp';
protocols = {'async', 'sync', 'residual'};
for i=1:numel(protocols)
    dgm.infEngArgs = {'updateProtocol', protocols{i}}; 
    nodeBelsBP = dgmInferNodes(dgm); 
    assert(tfequal(nodeBelsJT, nodeBelsBP));
end