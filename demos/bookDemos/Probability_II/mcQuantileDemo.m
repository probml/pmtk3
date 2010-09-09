%% MC Quantile Demo
%
%%

% This file is from pmtk3.googlecode.com

mu = 0; sigma = 1; % standard normal
S = 1000; % number of samples
setSeed(1); % set the seed for the random number generator
xs = gaussSample(mu, sigma, S); % sample from a Gaussian
qs = [0.025 0.5 0.975]; % desired quantiles
qexact = gaussinv(qs, mu, sigma) % exact quantiles using inverse cdf
%qexact =
%   -1.9600         0    1.9600
qapprox = quantilePMTK(xs, qs)' % MC quantiles
%qapprox =
%    -1.9652   -0.0503    1.8884  
if statsToolboxInstalled
  qapprox = quantile(xs, qs)' % MC quantiles
  %qapprox =
  %   -1.9657   -0.0556    1.8595
end
