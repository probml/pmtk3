function [W, Z, evals, Xrecon, mu, iter] = pcaEm(X, k)
% X is n*d - rows are examples, columns are features
% If k is not specified, we use the maximum possible value (rank(X))
% W is d*k (the basis vectors)
% Z is  n*k (the principal components)
% evals 
% Xrecon is n*d - reconstructed from first K
% mu is d*1

[n d] = size(X);
maxiter = 10;
if nargin < 2
  k = rank(X);
end
mu = mean(X);
X = X - repmat(mu, n, 1);
X = X'; % each *column* is now a centered data case

W = rand(d,k);
iter = 1; done = false; mse = inf;
while ~done
   Z =  W \ X; % E step
   %Z1 = inv(W'*W)*W'*X; 
   %assert(approxeq(Z, Z1))
   W = (X*Z')/(Z*Z'); % M step
   %W1 = X*Z'*inv(Z*Z'); % M step
   %assert(approxeq(W,W1))
   Xrecon = W*Z;
   oldmse = mse;
   mse = mean((Xrecon(:) - X(:)).^2);
   done = convergenceTest(mse, oldmse, 1e-2);
   iter = iter + 1;
   if iter > maxiter, done = true; end
end

% post process
W = orth(W);
X = X';
Z = X*W; % rows of Z are cases
% do usual pca on Z in O(k^3) time
[evecs, evals] = eig(Z'*Z/n);
[evals, perm] = sort(diag(evals), 'descend');
evecs = evecs(:, perm);
W = W*evecs;
Z = X*W;
Xrecon = Z*W' + repmat(mu, n, 1);




end