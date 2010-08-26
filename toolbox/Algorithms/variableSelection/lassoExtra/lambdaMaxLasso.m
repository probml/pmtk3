function lambda = lambdaMaxLasso(X, y)
% Largest possible L1 penalty which results in non-zero weight vector
lambda = norm(2*(X'*y),inf);

end