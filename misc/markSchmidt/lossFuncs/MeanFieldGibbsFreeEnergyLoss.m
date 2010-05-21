function [F,g] = MeanFieldGibbsFreeEnergyLoss(nodeBel,nodePot,edgePot,edgeEnds)

[nNodes,nStates] = size(nodePot);
nodeBel = reshape(nodeBel,nNodes,nStates);
nEdges = size(edgeEnds,1);

threshold = 1e-10;

U1 = 0;
U2 = 0;
S1 = 0;
g = zeros(nNodes,nStates);

for n = 1:nNodes
    % Local Mean-Field Average Energy Term
    b = nodeBel(n,:);
    U1 = U1 + sum(b .* log(nodePot(n,:)));
    g(n,:) = g(n,:) - log(nodePot(n,:));

    % Mean-Field Entropy Term
    b = nodeBel(n,:);
    b(b < threshold) = 1;
    S1 = S1 + sum(b.* log(b));
    g(n,:) = g(n,:) + log(b)+1;
end

for e = 1:nEdges
    n1 = edgeEnds(e,1);
    n2 = edgeEnds(e,2);

    b_i = repmat(nodeBel(n1,:)',1,nStates);
    b_j = repmat(nodeBel(n2,:),nStates,1);
    pot_ij = edgePot(:,:,e);

    % Pairwise Mean-Field Average Energy Term
    U2 = U2 + sum(b_i(:).*b_j(:).*log(pot_ij(:)));
    g(n1,:) = g(n1,:) - sum((b_j.*log(pot_ij))');
    g(n2,:) = g(n2,:) - sum(b_i.*log(pot_ij));
end
F = - U2 - U1 + S1;

g = g(:);