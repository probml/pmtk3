function df = linregDofL2(X, lambdas, doCenter)
% Compute the degrees of freedom for a given lambda value
% Elements 1e p63, 2e p68
% X should *not* include a column of 1s

% This file is from pmtk3.googlecode.com

if nargin < 3, doCenter  = true; end
[n,d] = size(X);
if d==0, df = 0; return; end
if doCenter
  XC  = centerCols(X);
else
  XC = X;
end
D22 = eig(XC'*XC); % evals of X'X = svals^2 of X
D22 = sort(D22, 'descend');
D22 = D22(1:min(n,d));

[U,D,V] = svd(XC,'econ');                                           %#ok
D2 = diag(D.^2);
assert(approxeq(D2,D22))

D2 = D22;
nlambdas = length(lambdas);
df = zeros(nlambdas,1);
lambdas  = lambdas+eps;
for i=1:nlambdas
  df(i) = sum(D2./(D2+lambdas(i)));
end

      
end
