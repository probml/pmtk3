function [B, Z, evals, Xrecon, mu] = pcaFast(X, K, method)
% X is n*d - rows are examples, columns are features
% If K is not specified, we use the maximum possible value (min(n,d))
% B is d*K (the basis vectors)
% Z is  n*K (the low dimensional representation)
% evals(1:K) is a vector of all eigenvalues 
% Xrecon is n*d - reconstructed from first K
% mu is d*1

[n d] = size(X);
if nargin < 2
  %K = min(n,d); 
  K = rank(X);
end
if nargin < 3
  cost = [d^3 n^3 min(n*d^2, d*n^2)];
  [junk, method] = min(cost);
end

methodNames = {'eig(Xt X)', 'eig(X Xt)', 'SVD(X)'};
%fprintf('using method %s\n', methodNames{method});

mu = mean(X);
X = X - repmat(mu, n, 1);
switch method
 case 1,
  %[evec, evals] = eig(cov(X));
  [evec, evals] = eig(X'*X/n);
  [evals, perm] = sort(diag(evals), 'descend');
  B = evec(:, perm(1:K));
 case 2,
  [evecs, evals] = eig(X*X');
  [evals, perm] = sort(diag(evals), 'descend');
  V = evecs(:, perm);
  B = (X'*V)*diag(1./sqrt(evals));
  B = B(:, 1:K);
  evals = evals / n;
  r = rank(X);
  evals(r+1:end) = 0;
 case 3,
  [U,S,V] = svd(X,0);
  B = V(:,1:K);
  evals = (1/n)*diag(S).^2;
 case 4,
  [U,S,V] = svds(X,K); % slow
  B = V(:,1:K);
  evals = (1/n)*diag(S).^2;
end
Z = X*B;
Xrecon = Z*B' + repmat(mu, n, 1);

