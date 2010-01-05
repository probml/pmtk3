function x = randbeta(a,b)
% RANDBETA   Sample from Beta distribution
%
% X = RANDBETA(A,B) returns a matrix, the same size as A and B, where X(i,j)
% is sampled from a Beta(A(i,j),B(i,j)) distribution.
% A or B can be scalar when the other is a matrix, otherwise they must be
% the same size.

if length(a) == 1
  a = repmat(a,size(b));
elseif length(b) == 1
  b = repmat(b,size(a));
end
x = randgamma(a);
x = x./(x + randgamma(b));
