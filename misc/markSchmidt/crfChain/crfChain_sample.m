function [samples] = crfChian_infer(nodePot,edgePot,nSamples)

[nNodes,nStates] = size(nodePot);

% Forward Pass
alpha = zeros(nNodes,nStates);
alpha(1,:) = nodePot(1,:);
Z(1) = sum(alpha(1,:));
alpha(1,:) = alpha(1,:)/Z(1);
for n = 2:nNodes % Forward Pass
    tmp = repmat(alpha(n-1,:)',1,nStates).*edgePot;
    alpha(n,:) = nodePot(n,:).*sum(tmp);
    
    % Normalize
    Z(n) = sum(alpha(n,:));
    alpha(n,:) = alpha(n,:)/Z(n);
end

samples = zeros(nNodes,nSamples);
y = zeros(nNodes,1);

for s = 1:nSamples
    % Backward Pass
    y(nNodes) = sampleDiscrete(alpha(nNodes,:));
    for n = nNodes-1:-1:1
        pot_ij = alpha(n,:)'.*edgePot(:,y(n+1));
        y(n) = sampleDiscrete(pot_ij./sum(pot_ij));
    end
    samples(:,s) = y;
end