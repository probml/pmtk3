function maxLambda = groupLassoMaxLambda(groups, X, y)
% Find the largest regularizer that drives all params to 0
% This is given by
%   max_groups sqrt( sum_{i in g} gradient(g,i)^2 )
% where the gradient is evaluated at the all 0s weight vector.
% We exclude group 0 (representing the unregularized terms)
funObj1 = @(w)SquaredError(w,X,y);
nVars = size(X,2);
[f,g] = funObj1(zeros(nVars,1)); %#ok
grad_norms = sqrt(accumarray(groups(groups~=0),g(groups~=0).^2));
maxLambda = max(grad_norms);