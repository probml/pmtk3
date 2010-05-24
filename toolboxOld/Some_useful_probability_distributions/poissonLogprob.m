function [logp, L] = poissonLogprob(model, X)
% logp(i) = sum_j log p(X(i, j) | model.lambda(j))
% L(i, j) = log(p(X(i, j) | model.lambda(j))

lambda = model.lambda;
if numel(lambda) == 1
    X = colvec(X);
end
[n, d] = size(X);
L = zeros(n, d);
for j=1:d
    Xj = X(:, j);
    L(:, j) = Xj .* log(lambda(j)) - factorialln(Xj) - lambda(j);
end
logp = sum(L, 2);

end


