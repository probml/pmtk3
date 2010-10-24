function M = softeye(K, p)
% Make a stochastic matrix with p on the diagonal, and the remaining mass distributed uniformly
%
% M is a K x K matrix.

% This file is from pmtk3.googlecode.com


M = p*eye(K);
q = 1-p;
for i=1:K
    M(i, [1:i-1  i+1:K]) = q / (K-1);
end
