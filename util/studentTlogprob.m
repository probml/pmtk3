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
    
    test = false;
    if test % make sure multivar equations give same results as scalar equations in the scalar case
        s2 = Sigma;
        logZ = -gammaln(v/2 + 1/2) + gammaln(v/2) + 0.5 * log(v .* pi .* s2);
        M = repmat(rowvec(mu), N, 1);
        S2 = repmat(rowvec(s2), N, 1);
        V = repmat(rowvec(v), N, 1);
        LZ = repmat(rowvec(logZ), N, 1);
        Lij = (-(V+1)/2) .* log(1 + (1./V).*( (X-M).^2 ./ S2 ) ) - LZ;
        L = sum(Lij,2);
        assert(approxeq(L, logp))
    end
    
    
    
end