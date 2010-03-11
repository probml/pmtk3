function X = addOnes(X)
% add a column of ones to X
    X = [ones(size(X, 1), 1), X];
end