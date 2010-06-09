function  [nodeBel, edgeBel, logZ] = UGM_Infer_Tree(nodePot, edgePot, edgeStruct)
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeBel(node,class) - marginal beliefs
% edgeBel(class,class,e) - pairwise beliefs
% logZ - negative of free energy

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
nStates = edgeStruct.nStates;
V = edgeStruct.V;
E = edgeStruct.E;

% Compute Messages
maximize = 0;
messages = UGM_TreeBP(nodePot,edgePot,edgeStruct,maximize);

% Compute nodeBel
for n = 1:nNodes
   nodeBel(n,1:nStates(n)) = nodePot(n,1:nStates(n));

   edges = E(V(n):V(n+1)-1);
   for e = edges(:)'
      if n == edgeEnds(e,2)
         nodeBel(n,1:nStates(n)) = nodeBel(n,1:nStates(n)).*messages(1:nStates(n),e)';
      else
         nodeBel(n,1:nStates(n)) = nodeBel(n,1:nStates(n)).*messages(1:nStates(n),e+nEdges)';
      end

   end
   nodeBel(n,1:nStates(n)) = nodeBel(n,1:nStates(n))./sum(nodeBel(n,1:nStates(n)));
end

if nargout > 1
   % Compute edgeBel
   messages(messages==0) = inf; % Do the right thing for divide by zero case
   edgeBel = zeros(maxState,maxState,nEdges);
   for e = 1:nEdges
      n1 = edgeEnds(e,1);
      n2 = edgeEnds(e,2);
      belN1 = nodeBel(n1,1:nStates(n1))'./messages(1:nStates(n1),e+nEdges);
      belN2 = nodeBel(n2,1:nStates(n2))'./messages(1:nStates(n2),e);
      b1=repmat(belN1,1,nStates(n2));
      b2=repmat(belN2',nStates(n1),1);
      eb = b1.*b2.*edgePot(1:nStates(n1),1:nStates(n2),e);
      edgeBel(1:nStates(n1),1:nStates(n2),e) = eb./sum(eb(:));
   end
end

if nargout > 2
   % Compute Bethe free energy 
   % (Z could also be computed as normalizing constant for any node in the tree
   %    if unnormalized messages are used)
   Energy1 = 0; Energy2 = 0; Entropy1 = 0; Entropy2 = 0;
   nodeBel = nodeBel+eps;
   edgeBel = edgeBel+eps;
   for n = 1:nNodes
      edges = E(V(n):V(n+1)-1);
      nNbrs = length(edges);

      % Node Entropy (can get divide by zero if beliefs at 0)
      Entropy1 = Entropy1 + (nNbrs-1)*sum(nodeBel(n,1:nStates(n)).*log(nodeBel(n,1:nStates(n))));

      % Node Energy
      Energy1 = Energy1 - sum(nodeBel(n,1:nStates(n)).*log(nodePot(n,1:nStates(n))));
   end
   for e = 1:nEdges
      n1 = edgeEnds(e,1);
      n2 = edgeEnds(e,2);

      % Pairwise Entropy (can get divide by zero if beliefs at 0)
      eb = edgeBel(1:nStates(n1),1:nStates(n2),e);
      Entropy2 = Entropy2 - sum(eb(:).*log(eb(:)));

      % Pairwise Energy
      ep = edgePot(1:nStates(n1),1:nStates(n2),e);
      Energy2 = Energy2 - sum(eb(:).*log(ep(:)));
   end
   F = (Energy1+Energy2) - (Entropy1+Entropy2);
   logZ = -F;
end
end
