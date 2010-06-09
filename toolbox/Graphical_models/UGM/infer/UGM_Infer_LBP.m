function [nodeBel, edgeBel, logZ] = UGM_Infer_LBP(nodePot,edgePot,edgeStruct)

if edgeStruct.useMex
    [nodeBel,edgeBel,logZ] = UGM_Infer_LBPC(nodePot,edgePot,int32(edgeStruct.edgeEnds),int32(edgeStruct.nStates),int32(edgeStruct.V),int32(edgeStruct.E),edgeStruct.maxIter);
else
    [nodeBel, edgeBel, logZ] = Infer_LBP(nodePot,edgePot,edgeStruct);
end

end

function [nodeBel, edgeBel, logZ] = Infer_LBP(nodePot,edgePot,edgeStruct)

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;

maximize = 0;
new_msg = UGM_LoopyBP(nodePot,edgePot,edgeStruct,maximize);


% Compute nodeBel
for n = 1:nNodes
    edges = E(V(n):V(n+1)-1);
    prod_of_msgs(1:nStates(n),n) = nodePot(n,1:nStates(n))';
    for e = edges(:)'
        if n == edgeEnds(e,2)
            prod_of_msgs(1:nStates(n),n) = prod_of_msgs(1:nStates(n),n) .* new_msg(1:nStates(n),e);
        else
            prod_of_msgs(1:nStates(n),n) = prod_of_msgs(1:nStates(n),n) .* new_msg(1:nStates(n),e+nEdges);
        end
    end
    nodeBel(n,1:nStates(n)) = prod_of_msgs(1:nStates(n),n)'./sum(prod_of_msgs(1:nStates(n),n));
end

if nargout > 1
    % Compute edge beliefs
    edgeBel = zeros(maxState,maxState,nEdges);
    for e = 1:nEdges
        n1 = edgeEnds(e,1);
        n2 = edgeEnds(e,2);
        belN1 = nodeBel(n1,1:nStates(n1))'./new_msg(1:nStates(n1),e+nEdges);
        belN2 = nodeBel(n2,1:nStates(n2))'./new_msg(1:nStates(n2),e);
        b1=repmatC(belN1,1,nStates(n2));
        b2=repmatC(belN2',nStates(n1),1);
        eb = b1.*b2.*edgePot(1:nStates(n1),1:nStates(n2),e);
        edgeBel(1:nStates(n1),1:nStates(n2),e) = eb./sum(eb(:));
    end
end

if nargout > 2
    % Compute Bethe free energy
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