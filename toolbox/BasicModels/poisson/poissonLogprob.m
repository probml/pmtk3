function [logp, L] = poissonLogprob(arg1, X)
% logp(i) = sum_j log p(X(i, j) | lambda(j))
% L(i, j) = log(p(X(i, j) | lambda(j))
% arg1 is either a model with field lambda, or just lambda itself. 
%%

% This file is from pmtk3.googlecode.com

if isstruct(arg1)
    model = arg1; 
    lambda = model.lambda; 
else
    lambda = arg1; 
end

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


