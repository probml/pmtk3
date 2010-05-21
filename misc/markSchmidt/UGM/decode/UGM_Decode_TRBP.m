function [nodeLabels] = UGM_Decode_TRBP(nodePot,edgePot,edgeStruct)
% Assumes no ties

nEdges = size(edgePot,3);

% Compute Edge Appearance Probabilities
if 0 
    % Ordinary BP
    mu = ones(nEdges,1);
else
    % Generate Random Spanning Trees until all edges are covered
    [nNodes,maxState] = size(nodePot);
    edgeEnds = edgeStruct.edgeEnds;
    
    i = 0;
    edgeAppears = zeros(nEdges,1);
    while 1
        i = i+1;
        edgeAppears = edgeAppears+minSpan(nNodes,[edgeEnds rand(nEdges,1)]);
        if all(edgeAppears > 0)
            break;
        end
    end
    mu = edgeAppears/i;
end


maximize = 1;
new_msg = UGM_TRBP(nodePot,edgePot,edgeStruct,maximize,mu);

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;


%% Compute nodeBel
nodeBel = zeros(nNodes,maxState);
for n = 1:nNodes
    edges = E(V(n):V(n+1)-1);
    prod_of_msgs(1:nStates(n),n) = nodePot(n,1:nStates(n))';
    for e = edges(:)'
        if n == edgeEnds(e,2)
            prod_of_msgs(1:nStates(n),n) = prod_of_msgs(1:nStates(n),n) .* (new_msg(1:nStates(n),e).^mu(e));
        else
            prod_of_msgs(1:nStates(n),n) = prod_of_msgs(1:nStates(n),n) .* (new_msg(1:nStates(n),e+nEdges).^mu(e));
        end
    end
    nodeBel(n,1:nStates(n)) = prod_of_msgs(1:nStates(n),n)'./sum(prod_of_msgs(1:nStates(n),n));
end

[pot nodeLabels] = max(nodeBel,[],2);
