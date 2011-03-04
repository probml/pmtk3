


%{ 
Example:  
 Graph is this: 
      1 
     /  \ 
    2    3
    |
    4

 Let us tie the 1-2 and 1-3 edges.
%}


G = zeros(4,4); G(1,[2 3]) = 1; G(2,4) = 1; G = mkSymmetric(G);
Nnodes = size(G,1);
edgePot12 = [1 2; 3 4];
edgePot24 = [5 6; 7 8];
edgePots = zeros(2,2,2);
edgePots(:,:,1) = edgePot12;
edgePots(:,:,2) = edgePot24;
edgePotNdx = zeros(Nnodes, Nnodes);
edgePotNdx(1,2) = 1; edgePotNdx(1,3) = 1; edgePotNdx(2,4) = 2;
%nodePots = ones(2,1);
%nodePotNdx = ones(1,Nnodes); % share the same nodePot everywhere
nodePots = [1 2 3 4;
            5 6 7 8];
nodePotNdx = 1:4;
model = treegmCreate(G, nodePots, edgePots, nodePotNdx, edgePotNdx);



% convert 'naked' potentials into labeled factors
factors = {};
Nnodes = size(G,1);
for i=1:Nnodes
  n = nodePotNdx(i);
  factors{end+1} = tabularFactorCreate(nodePots(:, n), i);
end
for i=1:Nnodes
  for j=1:Nnodes
    e = edgePotNdx(i,j);
    %fprintf('i=%d,j=%d,e=%d\n', i, j, e);
    if e ~= 0
      factors{end+1} = tabularFactorCreate(edgePots(:,:,e), [i j]);
    end
  end
end



[logZB, nodeBelB, edgeBelB] = bruteForceInferNodes(factors, model.edges);
[logZB2, nodeBelB2, edgeBelB2] = treegmInferNodes(model);


assert(approxeq(logZB, logZB2))
assert(approxeq(nodeBelB, nodeBelB2))
assert(approxeq(edgeBelB, edgeBelB2))


