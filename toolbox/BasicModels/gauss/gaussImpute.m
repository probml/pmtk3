function [Xc, V] = gaussImpute(model, X)
% Fill in NaN entries of X using posterior mode on each row
% Xc(i,j) = E[X(i,j) | D]
% V(i,j) = Variance

% This file is from pmtk3.googlecode.com

[n,d] = size(X);
Xc = X;
V = zeros(n,d);
for i=1:n
    hidNodes = find(isnan(X(i,:)));
    if isempty(hidNodes), continue, end;
    visNodes = find(~isnan(X(i,:)));
    visValues = X(i,visNodes);
    modelHgivenV = gaussCondition(model, visNodes, visValues);
    Xc(i, hidNodes) = rowvec(modelHgivenV.mu);
    V(i, hidNodes) = rowvec(diag(modelHgivenV.Sigma));
end
end

