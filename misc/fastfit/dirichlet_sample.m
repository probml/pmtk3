function r = dirichlet_sample(a,n)
% DIRICHLET_SAMPLE   Sample from Dirichlet distribution.
%
% DIRICHLET_SAMPLE(a) returns a probability vector sampled from a 
% Dirichlet distribution with parameter vector A.
% DIRICHLET_SAMPLE(a,n) returns N samples, collected into a matrix, each 
% vector having the same orientation as A.
%
%   References:
%      [1]  L. Devroye, "Non-Uniform Random Variate Generation", 
%      Springer-Verlag, 1986

% This is essentially a generalization of the method for Beta rv's.
% Theorem 4.1, p.594

if nargin < 2
  n = 1;
end

row = (size(a, 1) == 1);

a = a(:);
%y = gamrnd(repmat(a, 1, n),1);
% randgamma is faster
y = randgamma(repmat(a, 1, n));
r = col_sum(y);
r(find(r == 0)) = 1;
r = y./repmat(r, size(y, 1), 1);
if row
  r = r';
end

end
