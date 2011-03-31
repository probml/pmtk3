function model = treegmCreate(G, nodePot, edgePot, nodePotNdx, edgePotNdx, ...
  localCPDs, localCPDpointers)
% Create a tree-structured graphical model
% We assume all nodes are discrete and have the same number of states.
% G is sparse adjacency matrix
% nodePot(:,n) is potential for node of type n
% edgePot(:,:,e) is potential for edge of type e
% nodePotNdx(s) = n means node s is of type n
% edgePotNdx(s,t) = e means edge s-t is of type e
%   We assume edgePot(:,:,e) has rows indexing s and columns indexing t
%   Hence for t-s we use edgePot(:,:,e)'
%   Thus either edgePotNdx(t,s)=0 or edgePotNdx(s,t) = 0.
% If nodePotNdx = 1:D, we use a different potential for each node.
% However, we can also share potentials across nodes, saving space.
% Similarly for edges.
%
% localCPDs{c} (eg output of condGaussCpdCreate) is local observation
%    model for nodes of type c
% localCPDpointers(t) = c means node t is of type c
% Both of these can be omitted

% model.edges(:,e) = [s t], edges order from leaves to root

model.adjmat = G;
model.nodePot = nodePot;
model.edgePot = edgePot;
model.nodePotNdx = nodePotNdx;
model.edgePotNdx = edgePotNdx;
model.Nstates = size(nodePot,1);
model.Nnodes = numel(nodePotNdx);

model.root = 1;
[model.edges] = treeMsgOrderPmtk(model.adjmat, model.root);

roots = [];
for i=1:model.Nnodes
  nbrs = neighbors(G, i);
  if isempty(nbrs)
    roots = [roots i];
  end
end
model.roots = roots;

%edgeorder = treeMsgOrder(model.adjmat, model.root);
% edgeorder(e,:) = [c p] for up  sweep
%model.edges = edgeorder(1:(size(edgeorder,1)/2),:);

model.Nedges = size(model.edges, 1);



% local evidence CPDs
if nargin < 6, localCPDs = []; end
if nargin < 7, localCPDpointers = 1:model.Nnodes; end
model.obsmodel.localCPDs = localCPDs;
model.obsmodel.localCPDpointers = localCPDpointers;
end
