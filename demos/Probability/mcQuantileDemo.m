%% MC Quantile Demo
%
%%
mu = 0; sigma = 1; % standard normal
S = 1000; % number of samples
setSeed(1); % set the seed for the random number generator
model = struct('mu', mu, 'Sigma', sigma);
xs = gaussSample(model, S); % sample from a Gaussian
qs = [0.025 0.5 0.975]; % desired quantiles
qexact = gaussinv(qs, mu, sigma) % exact quantiles using inverse cdf
%qexact =
%   -1.9600         0    1.9600
qapprox = quantilePMTK(xs, qs)' % MC quantiles
%qapprox =
%   -1.9657   -0.0556    1.8595