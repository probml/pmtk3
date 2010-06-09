function logp = gaussLogprob(model, X)
% Multivariate Gaussian distribution, log pdf
% model is a struct with fields mu and Sigma
% X(i,:) is i'th case, can contain NaNs for missing values
% In the univariate case, Sigma is the variance, not the SD.
%%
if any(isnan(X(:)))
    logp = gaussLogprobMissingData(model, X);
    return;
end
mu   = model.mu; Sigma = model.Sigma;
d    = size(Sigma, 2);
X    = reshape(X, [], d);
X    = bsxfun(@minus, X, rowvec(mu));
logp = -0.5*sum((X/Sigma).*X, 2);
logZ = (d/2)*log(2*pi) + 0.5*logdet(Sigma);
logp = logp - logZ;
end