function [lam, u, iter] =  powerMethod(C)
% Power method for finding the leading eigenvalue/ vector of a pd matrix

% This file is from pmtk3.googlecode.com


maxIter = 100;
tol = 1e-10;
converged = 0;

n = length(C);
u = randn(n,1); u = u / norm(u);
iter = 1;
while ~converged & (iter < maxIter)
  oldu = u;
  u = C*u;
  u = u / norm(u);
  lam = u'*C*u;
  converged = (norm(u - oldu) < tol);
  iter = iter + 1;
end
if iter > maxIter
  warning('did not converge')
end
 
end
