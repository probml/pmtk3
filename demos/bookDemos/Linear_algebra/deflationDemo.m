%% Compute largest K eigenvectors and eigenvalues of a symmetric matrix
% We us the power method combined with successive deflation
%%

% This file is from pmtk3.googlecode.com

setSeed(0); 
n = 10; d = 3;
X = randn(n,d);
C = (1/n)*X'*X;

K = 3;
[V1, lambda1] = deflation(C, K)

[evec, evals] = eig(C);
[evals, perm] = sort(diag(evals), 'descend');
V2 = evec(:, perm(1:K));
lambda2 = evals;

assert(approxeq(abs(V1), abs(V2)));
assert(approxeq(lambda1(1:K), lambda2(1:K)))
