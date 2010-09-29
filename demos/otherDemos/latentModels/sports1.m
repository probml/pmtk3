% test for jo-anne

G = zeros(5,5);
nodePot = ones(2,1);
edgePots = [];
model     = mrfCreate(G, 'nodePots', nodePot, 'edgePots', edgePots);
bel = mrfInferNodes(model)



