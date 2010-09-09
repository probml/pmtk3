function p = uniGaussPdf(X, mu, sigma2)
%% Univariate Gaussian PDF vectorized w.r.t. mu and sigma2
% p(i) = p(X(i) | mu(i), sigma2(i))
% Use this function when you want to evaluate each data case under a
% different distribution, i.e. different mu and sigma2 values, otherwise
% use gaussProb, which works in the uni and multivariate case. 
%%

% This file is from pmtk3.googlecode.com

X      = colvec(X);
mu     = colvec(mu);
sigma2 = colvec(sigma2);
logZ   = log(sqrt(2.*pi.*sigma2));
logp   = -0.5.*((X-mu).^2)./sigma2;
p      = exp(logp - logZ); 
end
