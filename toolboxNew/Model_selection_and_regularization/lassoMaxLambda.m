function maxLambda = lassoMaxLambda(X, y)
% Find the largest regularizer that drives all params to 0
maxLambda = norm(2*(X'*y),inf);

end