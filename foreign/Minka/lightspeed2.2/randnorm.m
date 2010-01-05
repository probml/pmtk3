function x = randnorm(n, m, S, V)
% RANDNORM      Sample from multivariate normal.
% RANDNORM(n,m) returns a matrix of n columns where each column is a sample 
% from a multivariate normal with mean m (a column vector) and unit variance.
% RANDNORM(n,m,S) specifies the standard deviation, or more generally an 
% upper triangular Cholesky factor of the covariance matrix.  
% This is the most efficient option.
% RANDNORM(n,m,[],V) specifies the covariance matrix.
%
% Example:
%   x = randnorm(5, zeros(3,1), [], eye(3));

if nargin == 1
  x = randn(1,n);
  return;
end
[d,nm] = size(m);
x = randn(d, n);
if nargin > 2
  if nargin == 4
    if d == 1
      S = sqrt(V);
    else
      S = chol(V);
    end
  end
  if d == 1
    x = S .* x;
  else
    x = S' * x;
  end
end
if nm == 1
  x = x + repmat(m, 1, n);
else
  x = x + m;
end
