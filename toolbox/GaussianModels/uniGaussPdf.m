function p = uniGaussPdf(X, mu, sigma2)
%% Univariate Gaussian PDF vectorized w.r.t. mu and sigma2
% p(i) = p(X(i) | mu(i), sigma2(i))
%%
X      = colvec(X);
mu     = colvec(mu);
sigma2 = colvec(sigma2);
logZ   = log(sqrt(2.*pi.*sigma2));
logp   = -0.5.*((X-mu).^2)./sigma2;
p      = exp(logp - logZ); 
end