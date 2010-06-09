function [f,g] = overLassoLoss(v,varGroupMatrix,lambda,funObj)
[nVars,nGroups] = size(varGroupMatrix);

vInd = find(varGroupMatrix==1);
alpha = v(length(vInd)+1:end);
v = v(1:length(vInd));

% Form sub-weight matrix vFull, and weight vector w
vFull = zeros(nVars,nGroups);
vFull(vInd) = v;
w = sum(vFull,2);

% Evaluate Loss
[f,grad_w] = funObj(w);

% Form gradient wrt v
grad_v = zeros(nVars,nGroups);
for g = 1:nGroups
    grad_v(varGroupMatrix(:,g)==1,g) = grad_w(varGroupMatrix(:,g)==1);
end

% Add contribution of regularizer
f = f + sum(lambda.*alpha);
g = [grad_v(varGroupMatrix(:)==1);lambda.*ones(nGroups,1)];
