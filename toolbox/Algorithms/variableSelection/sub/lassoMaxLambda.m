function maxLambda = lassoMaxLambda(X, y)
% Find the largest regularizer that drives all params to 0

% This file is from pmtk3.googlecode.com

maxLambda = norm(2*(X'*y),inf);

end
