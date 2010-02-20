function [L, Lij] = discreteLogprob(model, X)
% Compute the log probability of the data. X must be in 1:K.
% model is a structure with a field T, a model.K-by-d stochastic matrix, 
%(as returned by discreteFit).
%
% X(i, j) is the ith case from the jth distribution.
%
% Lij = log p(X(i, j) | params(j))
% L   = sum(Lij, 2)  % i.e. summed across distributions, (not cases).

X = reshape(X, [], model.d); 
n = size(X, 1);
T = model.T;
if model.K == 2
    % more efficient method if data is binary, we treat X01 as a mask for T
    X01 = (X == 2);
    logT = log(T + eps);
    L0 = bsxfun(@times, logT(1, :), not(X01));
    L1 = bsxfun(@times, logT(2, :), X01);
    Lij = L0 + L1;
    L = sum(Lij, 2);
else
    Lij = zeros(n, d);
    for j=1:d
        Lij(:, j) = log(T(X(:, j), j));
    end
    L = sum(Lij, 2);
end
end