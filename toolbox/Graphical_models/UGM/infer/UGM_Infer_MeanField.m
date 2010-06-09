function [nodeBel, edgeBel, logZ] = UGM_Infer_MF(nodePot,edgePot,edgeStruct)

if edgeStruct.useMex
    [nodeBel,edgeBel,logZ] = UGM_Infer_MFC(nodePot,edgePot,int32(edgeStruct.edgeEnds),int32(edgeStruct.nStates),int32(edgeStruct.V),int32(edgeStruct.E),edgeStruct.maxIter);
else
    [nodeBel,edgeBel,logZ] = Infer_MF(nodePot,edgePot,edgeStruct);
end

end



function [nodeBel, edgeBel, logZ] = Infer_MF(nodePot,edgePot,edgeStruct)

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;
maxIter = edgeStruct.maxIter;

nodeBel = nodePot;
for n = 1:nNodes
    nodeBel(n,:) = nodeBel(n,:)/sum(nodeBel(n,:));
end

for i = 1:maxIter
    oldNodeBel = nodeBel;

    for n = 1:nNodes
        b = zeros(1,nStates(n));

        % Find Neighbors
        edges = E(V(n):V(n+1)-1);
        for e = edges(:)'
            n1 = edgeEnds(e,1);
            n2 = edgeEnds(e,2);

            if n == edgeEnds(e,2);
                ep = edgePot(1:nStates(n1),1:nStates(n2),e);
                neigh = n1;
            else
                ep = edgePot(1:nStates(n1),1:nStates(n2),e)';
                neigh = n2;
            end

            for s_n = 1:nStates(n)
                b(s_n) = b(s_n) + nodeBel(neigh,1:nStates(neigh))*log(ep(1:nStates(neigh),s_n));
            end
        end
        nb(1,1:nStates(n)) = nodePot(n,1:nStates(n)).*exp(b);
        nodeBel(n,1:nStates(n)) = nb(1,1:nStates(n))/sum(nb(1,1:nStates(n)));
    end

    if sum(abs(nodeBel(:)-oldNodeBel(:))) < 1e-4
        break;
    end
end

% Compute edgeBel
edgeBel = zeros(size(edgePot));
for e = 1:nEdges
    n1 = edgeEnds(e,1);
    n2 = edgeEnds(e,2);
    for s1 = 1:nStates(n1)
        for s2 = 1:nStates(n2)
            edgeBel(s1,s2,e) = nodeBel(n1,s1)*nodeBel(n2,s2);
        end
    end
end

% Compute logZ
logZ = -UGM_MFGibbsFreeEnergy(nodePot,edgePot,nodeBel,nStates,edgeEnds,V,E);

end



