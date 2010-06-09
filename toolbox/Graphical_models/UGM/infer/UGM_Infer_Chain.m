function  [nodeBel, edgeBel, logZ] = UGM_Infer_Chain(nodePot, edgePot, edgeStruct)
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeBel(node,class) - marginal beliefs
% edgeBel(class,class,e) - pairwise beliefs
% logZ - negative of free energy
%
% NOTE: This code assumes that the edges are in order!
%		(use UGM_Infer_Tree if they are not)

if edgeStruct.useMex
    [nodeBel,edgeBel,logZ] = UGM_Infer_ChainC(nodePot,edgePot,int32(edgeStruct.nStates));
else
    [nNodes,maxState] = size(nodePot);
    nEdges = size(edgePot,3);
    edgeEnds = edgeStruct.edgeEnds;
    nStates = edgeStruct.nStates;
    maximize = 0;



    % Forward Pass
    [alpha,kappa] = UGM_ChainFwd(nodePot,edgePot,nStates,maximize);

    % Backward Pass
    beta = zeros(nNodes,maxState);
    beta(nNodes,1:nStates(nNodes)) = 1;
    for n = nNodes-1:-1:1
        tmp = repmatC(nodePot(n+1,1:nStates(n+1)),nStates(n),1).*edgePot(1:nStates(n),1:nStates(n+1),n);
        tmp2 = repmatC(beta(n+1,1:nStates(n+1)),nStates(n),1);
        beta(n,1:nStates(n)) = sum(tmp.*tmp2,2)';

        % Normalize
        beta(n,1:nStates(n)) = beta(n,1:nStates(n))/sum(beta(n,1:nStates(n)));
    end

    % Compute Node Beliefs
    nodeBel = zeros(size(nodePot));
    for n = 1:nNodes
        tmp = alpha(n,1:nStates(n)).*beta(n,1:nStates(n));
        nodeBel(n,1:nStates(n)) = tmp/sum(tmp);
    end

    % Compute Edge Beliefs
    edgeBel = zeros(size(edgePot));
    for n = 1:nNodes-1
        tmp = zeros(maxState);
        for i = 1:nStates(n)
            for j = 1:nStates(n+1)
                tmp(i,j) = alpha(n,i)*nodePot(n+1,j)*beta(n+1,j)*edgePot(i,j,n);
            end
        end
        edgeBel(:,:,n) = tmp./sum(tmp(:));
    end

    % Compute logZ
    logZ = sum(log(kappa));
end