
function [Xc, V] = mvnImpute(mu, Sigma, X)
% Fill in NaN entries of X using posterior mode on each row
% Xc(i,j) = E[X(i,j) | D]
% V(i,j) = Variance
[n,d] = size(X);
Xc = X;
V = zeros(n,d);
for i=1:n
  hidNodes = find(isnan(X(i,:)));
  if isempty(hidNodes), continue, end;
  visNodes = find(~isnan(X(i,:)));
  visValues = X(i,visNodes);
  [muHgivenV, SigmaHgivenV] = gaussCondition(mu, Sigma, visNodes, visValues);
  Xc(i,hidNodes) = rowvec(muHgivenV);
  V(i,hidNodes) = rowvec(diag(SigmaHgivenV));
end
end
    
 