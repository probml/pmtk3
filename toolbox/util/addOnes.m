function X = addOnes(X)
% Add a column of ones to X
    X = [ones(size(X, 1), 1), X];
end