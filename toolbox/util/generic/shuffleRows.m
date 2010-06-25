function [X, y] = shuffleRows(X, y)
% Randomly shuffle the rows of a matrix
n = size(X, 1); 
perm = randperm(n); 
X = X(perm, :); 
if nargin == 2
    y = y(perm, :); 
end

end