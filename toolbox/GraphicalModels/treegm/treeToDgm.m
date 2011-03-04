function dgm = treeToDgm(tree)
%  Make a directed version of an undirected tree
% so we can compute logprob efficiently
% We assume all nodes have the same number of states

fprintf('treeToDgm does not work\n');
% this is just because dgmCreate insists that nodes
% be topologically ordered, which is not really necessary

G =  mkRootedTree(tree.adjmat, tree.root);
Nnodes = size(G,1);
Nstates = tree.Nstates;
CPDs = cell(1,Nnodes);
for n=1:Nnodes
  nn = tree.nodePotNdx(n);
  if n==tree.root
    p = 0; %#ok
    CPDs{n} = tree.nodePot(:, nn);
  else
    p = parents(G, n);
    e = tree.edgePotNdx(p,n);
    if e ~= 0
      edgePot = tree.edgePot(:,:,e);
    else
       e = tree.edgePotNdx(n,p);
      edgePot = tree.edgePot(:,:,e)';
    end
    CPDs{n} = edgePot ./ repmat(tree.nodePot(:,nn)', Nstates, 1);
  end
end

dgm = dgmCreate(G, CPDs);
% this may fail if nodes are not topologically ordered

end


