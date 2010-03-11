function [X, y] = shuffleRows(X, y)

n = size(X, 1); 
perm = randperm(n); 
X = X(perm, :); 
y = y(perm, :); 

end