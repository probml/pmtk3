function tree = hmmToTree(model, T)
% Convert an hmm model to an undirected of by unrolling the hmm for T time steps
% Similar to hmmToDgm
%

% This file is from pmtk3.googlecode.com

G = mkChain(T); 
Nnodes = T;
Nstates = size(model.pi, 1);
nodePots = ones(Nstates, 2);
nodePots(:,1) = model.pi;
nodePotPointers = [1 2*ones(1,Nnodes-1)];


edges = sparse(Nnodes, Nnodes);
edgePotPointers = sparse(Nnodes, Nnodes);
e = 1;
for t=1:T-1
  edges(t,t+1) = e; %#ok
  edgePotPointers(t,t+1) = 1;
  e = e+1;
end
Nedges = Nnodes-1;
edgePots = model.A;


localCPDs = {model.emission};
localCPDpointers = ones(1, Nnodes);

tree = treegmCreate(G, nodePots, edgePots, nodePotPointers, edgePotPointers, ...
  localCPDs, localCPDpointers);


end
