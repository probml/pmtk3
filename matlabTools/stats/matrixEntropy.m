function H = matrixEntropy(v, scale)
% Calculate the entropy of a stochastic matrix
% If v is a matrix, H(j) = entropy(v(:,j)) ie each column should sum to one
%
% H = entropy(v,1) means we scale the result so that it lies in [0,1]

% This file is from pmtk3.googlecode.com


if nargin < 2, scale = 0; end

v = v + (v==0);
H = -1 * sum(v .* log2(v), 1); % sum the rows

if scale
  n = size(v, 1);
  unif = normalize(ones(n,1));
  H = H / entropy(unif);
end

end
