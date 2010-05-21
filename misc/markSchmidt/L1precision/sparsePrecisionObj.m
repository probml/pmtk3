function [f,g] = sparsePrecisionObj(x,nVars,nonZero,sigma)

X = zeros(nVars);
X(nonZero) = x;

[R,p] = chol(X);

if p== 0
    % Fast Way to compute -logdet(X) + tr(X*sigma)
    f = -2*sum(log(diag(R))) + sum(sum(sigma.*X));
    g = -inv(X) + sigma;
    g = g(nonZero);
else
    % Matrix not in positive-definite cone, set f to Inf
    %   to force minFunc to backtrack
    f = inf;
    g = zeros(size(x));
    
    % If backtracking too much:
    % optimal projection is given by projecting coefficients 
    % of spectral decomposition onto non-negative orthant)
end
