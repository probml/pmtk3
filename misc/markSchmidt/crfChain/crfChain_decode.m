function [y] = crfChian_decode(nodePot,edgePot)

[nNodes,nStates] = size(nodePot);

% Forward Pass
alpha = zeros(nNodes,nStates);
alpha(1,:) = nodePot(1,:);
Z(1) = sum(alpha(1,:));
alpha(1,:) = alpha(1,:)/Z(1);
for n = 2:nNodes % Forward Pass
    tmp = repmat(alpha(n-1,:)',1,nStates).*edgePot;
    alpha(n,:) = nodePot(n,:).*max(tmp);
    [mxPot mxState(n,:)] = max(tmp);
    
    % Normalize
    Z(n) = sum(alpha(n,:));
    alpha(n,:) = alpha(n,:)/Z(n);
end

% Backward Pass
y = zeros(nNodes,1);
[mxPot y(nNodes)] = max(alpha(nNodes,:));
for n = nNodes-1:-1:1
   y(n) = mxState(n+1,y(n+1));
end