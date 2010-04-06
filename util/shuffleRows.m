function [X, y] = shuffleRows(X, y)

n = size(X, 1); 
perm = randperm(n); 
X = X(perm, :); 
if nargin == 2
    y = y(perm, :); 
end

end