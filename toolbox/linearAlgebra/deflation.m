function [V,lambda] = deflation(C, K)
% Compute largest K eigenvectors and eigenvalues of symmetric matrix
% using power method combined with successive deflation
% Based on code by Mark Girolami

d = length(C);
V = zeros(d,K);
for j=1:K
  [lambda(j), V(:,j)] = powerMethod(C);
  C = C - lambda(j)*V(:,j)*V(:,j)'; % deflation
end

