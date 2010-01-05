function lambda = lambdaMaxL1(X, y)
% Largest possible L1 penalty which results in non-zero weight vector
lambda = norm(2*(X'*y),inf);
