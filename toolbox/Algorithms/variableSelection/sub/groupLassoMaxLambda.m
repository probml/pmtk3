function maxLambda = groupLassoMaxLambda(groups, X, y)
% Find the largest regularizer that drives all params to 0
% This is given by
%   max_groups sqrt( sum_{i in g} gradient(g,i)^2 )
% where the gradient is evaluated at the all 0s weight vector.
% We exclude group 0 (representing the unregularized terms)

% This file is from pmtk3.googlecode.com


nVars = size(X,2);
w = zeros(nVars,1);

biasObj = @(b)SquaredError(b,X(:,groups==0),y);
options.Display = 0;
w(groups==0) = minFunc(biasObj,w(groups==0),options);

funObj1 = @(w)SquaredError(w,X,y);
[f,g] = funObj1(w);
grad_norms = sqrt(accumarray(groups(groups~=0),g(groups~=0).^2));
maxLambda = max(grad_norms);

end
