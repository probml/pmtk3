function C = covmat(X)
% Same as cov(X) except Octave compatible.   
    N = size(X, 1);
    Xc = bsxfun(@minus, X, sum(X, 1)/N);  % Remove mean
    C = (Xc' * Xc) / (N-1);
end