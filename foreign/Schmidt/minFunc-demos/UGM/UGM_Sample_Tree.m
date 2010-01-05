function  [samples] = UGM_Sample_Tree(nodePot, edgePot, edgeStruct)
% Note: structure must be a tree 
% (does not currently support forests like other Tree functions)

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
nStates = edgeStruct.nStates;
V = edgeStruct.V;
E = edgeStruct.E;
maxIter = edgeStruct.maxIter;

% Compute Messages
maximize = 0;
messages = UGM_TreeBP(nodePot,edgePot,edgeStruct,maximize);

% Now generate samples
samples = zeros(nNodes,0);
y = zeros(nNodes,1);

root = 1;
for s = 1:maxIter
    
    % Sample Tree
    sample = -ones(nNodes,1);
    
    for root = 1:nNodes
        if sample(root) == -1
            % Each time this alternation is called, a different
            % tree in the forest will be sampled
            % (it is called only once if there is only one tree)
            sample = sampleFromTree(root,nodePot,edgePot,messages,edgeStruct,sample);
        end
    end
    samples(:,s) = sample;
end

end

function y = sampleFromTree(n,nodePot,edgePot,messages,edgeStruct,y)
nStates = edgeStruct.nStates;
V = edgeStruct.V;
E = edgeStruct.E;
edgeEnds = edgeStruct.edgeEnds;

y(n) = 0; % Root is expanded

nodeBel = nodePot(n,1:nStates(n))';

% Find Neighbors
edges = E(V(n):V(n+1)-1);

for e = edges(:)'
    n1 = edgeEnds(e,1);
    n2 = edgeEnds(e,2);
    
    if n == edgeEnds(e,2)
       neighbor = edgeEnds(e,1); 
    else
        neighbor = edgeEnds(e,2);
    end
    
    if y(neighbor) == -1
       % Expand Neighbor
       ySub = sampleFromTree(neighbor,nodePot,edgePot,messages,edgeStruct,y);
       y = max(y,ySub);
       
       if n == edgeEnds(e,2)
          nodeBel = nodeBel.*edgePot(y(neighbor),1:nStates(n),e)'; 
       else
           nodeBel = nodeBel.*edgePot(1:nStates(n),y(neighbor),e);
       end
    elseif y(neighbor) == 0
        % Neighbor is a parent, integrate over it
        if n == edgeEnds(e,2)
           nodeBel = nodeBel.*messages(1:nStates(n),e); 
        else
            nodeBel = nodeBel.*messages(1:nStates(n),e+nEdges);
        end
    end
end
y(n) = sampleDiscrete(nodeBel./sum(nodeBel));

end

