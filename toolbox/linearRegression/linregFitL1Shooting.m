function w = linregFitL1Shooting(X, y, lambda)
% min_w ||Xw-y||_2^2 + sum_j lambda(j) |w_j|
% Coordinate descent method  ("Shooting"), [Fu, 1998]
w = LassoShooting(X, y, lambda);
end
