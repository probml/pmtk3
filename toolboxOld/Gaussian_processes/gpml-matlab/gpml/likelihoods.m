% likelihood: likelihood functions are provided to be used by the binaryGP
% function, for binary Gaussian process classification. Two likelihood
% functions are provided:
%
%   logistic    
%   cumGauss
%
% The likelihood functions have three possible modes, the mode being selected
% as follows (where "lik" stands for any likelihood function):
%
% (log) likelihood evaluation: [p, lp] = lik(y, f)
%     
%   where y are the targets, f the latent function values, p the probabilities
%   and lp the log probabilities. All vectors are the same size.
%
% derivatives (of the log): [lp, dlp, d2lp, d3lp] = lik(y, f, 'deriv')
%
%   where lp is a number (sum of the log probablities for each case) and the
%   derivatives (up to order 3) of the logs wrt the latent values are vectors
%   (as the likelihood factorizes there are no mixed terms).
%
% moments wrt Gaussian measure: [m0, m1, m2] = lik(y, mu, var)
%
%   where mk is the k'th moment: \int f^k lik(y,f) N(f|mu,var) df, and if y is
%   empty, it is assumed to be a vector of ones.
%
% See the help for the individual likelihood for the computations specific to
% each likelihood function.
%
% Copyright (c) 2007 Carl Edward Rasmussen and Hannes Nickisch 2007-04-11.
