mu = 0; sigma = 1; % standard normal
S = 1000; % number of samples
randn('state', 1); % set the seed for the random number generator
xs = normrnd(mu, sigma, 1, S); % sample from a Gaussian
qs = [0.025 0.5 0.975]; % desired quantiles
qexact = norminv(qs, mu, sigma) % exact quantiles using inverse cdf
%qexact =
%   -1.9600         0    1.9600
qapprox = quantile(xs, qs) % MC quantiles
%qapprox =
%   -1.9657   -0.0556    1.8595