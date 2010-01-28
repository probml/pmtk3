function logp = studentTlogprob(X, mu, Sigma, dof)
    % logp(i) = log p(X(i,:) | params)
    mu = rowvec(mu); % ensure row vector
    if length(mu)==1
        X = colvec(X); % ensure column vector
    end
    [N d] = size(X);
    if length(mu) ~= d
        error('X should be N x d')
    end
    M = repmat(mu, N, 1); % replicate the mean across rows
    mahal = sum(((X-M)*inv(Sigma)).*(X-M), 2);
    v = dof;
    logZ = -gammaln(v/2 + d/2) + gammaln(v/2) + 0.5*logdet(Sigma) + (d/2)*log(v) + (d/2)*log(pi);
    logp = -0.5*(v+d)*log(1+(1/v)*mahal) - logZ;
end