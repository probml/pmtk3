function lambda = lambdaMaxLasso(X, y)
% Largest possible L1 penalty which results in non-zero weight vector

% This file is from pmtk3.googlecode.com

lambda = norm(2*(X'*y),inf);

end
