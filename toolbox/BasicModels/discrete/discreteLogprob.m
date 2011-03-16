function [L, Lij] = discreteLogprob(arg1, X)
% Compute the log probability of the data. X must be in 1:K.
% [L, Lij] = discreteLogprob(model, X) or
% [L, Lij] = discreteLogprob(T, X)
%
% model is a structure with a field T, a K-by-d stochastic matrix,
%(as returned by discreteFit).
%
% X(i, j) is the ith case from the jth distribution.
%
% Lij = log p(X(i, j) | params(j))
% L   = sum(Lij, 2)  % i.e. summed across distributions, (not cases).
%%

% This file is from pmtk3.googlecode.com


if any(isnan(X(:)))
    [L, Lij] = discreteLogprobMissingData(arg1, X);
    return;
end

if isstruct(arg1)
    model = arg1;
    T = model.T;
    K = model.K;
    d = model.d;
else
    T = arg1;
    [K, d] = size(T);
end

X = reshape(X, [], d);
n = size(X, 1);
if K == 2
    % more efficient method if data is binary; we treat X as a mask for T
    X = (X == 2);
    logT = log(T + eps);
    L1 = bsxfun(@times, logT(2, :), X);
    L0 = bsxfun(@times, logT(1, :), not(X));
    Lij = L0 + L1;
    L = sum(Lij, 2);
else
    Lij = zeros(n, d);
    logT = log(T + eps);
    for j=1:d
        Lij(:, j) = logT(X(:, j), j); % loop is faster than sub2ind vectorized solution
    end
    L = sum(Lij, 2);
end
end
