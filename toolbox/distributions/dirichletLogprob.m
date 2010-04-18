function logp = dirichletLogprob(model, X)
% logp(i) = log p(X(i, :) | model.alpha)
%
% *** X is appended with [X, 1-sum(X, 2)] ***
%
% if model.alpha is a scalar it is automatically replicated to the right
% size. 
%
% *** Values outside of the simplex are given NaN values, not -Inf ***



X = [X, 1-sum(X, 2)];
K = size(X, 2); 
alpha = colvec(model.alpha); 
if length(alpha) == 1
    alpha = repmat(alpha, K, 1); 
end
logp = log(X)*(alpha-1); 
logp = logp + gammaln(sum(alpha)) - sum(gammaln(alpha)); 

logp(X(: , end) < 0 | sum(X, 2) ~= 1) = NaN;




end

