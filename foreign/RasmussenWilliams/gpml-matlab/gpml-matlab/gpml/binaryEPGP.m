function varargout = binaryEPGP(hyper, covfunc, varargin)

% binaryEPGP - The Expectation Propagation approximation for binary Gaussian
% process classification. Two modes are possible: training or testing: if no
% test cases are supplied, then the approximate negative log marginal
% likelihood and its partial derivatives wrt the hyperparameters is computed;
% this mode is used to fit the hyperparameters. If test cases are given, then
% the test set predictive probabilities are returned. The program is flexible
% in allowing a multitude of covariance functions.
%
% usage: [nlZ, dnlZ     ] = binaryEPGP(hyper, covfunc, x, y);
%    or: [p, mu, s2, nlZ] = binaryEPGP(hyper, covfunc, x, y, xstar);
%
% where:
%
%   hyper    is a (column) vector of hyperparameters
%   covfunc  is the name of the covariance function (see below)
%   lik      is the name of the likelihood function (see below)
%   x        is a n by D matrix of training inputs
%   y        is a (column) vector (of size n) of binary +1/-1 targets
%   xstar    is a nn by D matrix of test inputs
%   nlZ      is the returned value of the negative log marginal likelihood
%   dnlZ     is a (column) vector of partial derivatives of the negative
%               log marginal likelihood wrt each log hyperparameter
%   p        is a (column) vector (of length nn) of predictive probabilities
%   mu       is a (column) vector (of length nn) of predictive latent means
%   s2       is a (column) vector (of length nn) of predictive latent variances
%
% The length of the vector of hyperparameters depends on the covariance
% function, as specified by the "covfunc" input to the function, specifying the
% name of a covariance function. A number of different covariance function are
% implemented, and it is not difficult to add new ones. See "help covFunctions"
% for the details
%
% The function can conveniently be used with the "minimize" function to train
% a Gaussian process, eg:
%
% [hyper, fX, i] = minimize(hyper, 'binaryEPGP', length, 'covSEiso',
%                                                        'logistic', x, y);
%
% Copyright (c) 2004, 2005, 2006, 2007 Carl Edward Rasmussen, 2007-02-19.

if nargin<4 || nargin>5
  disp('Usage: [nlZ, dnlZ     ] = binaryEPGP(hyper, covfunc, x, y);')
  disp('   or: [p, mu, s2, nlZ] = binaryEPGP(hyper, covfunc, x, y, xstar);')
  return
end

% Note, this function is just a wrapper provided for backward compatibility,
% the functionality is now provided by the more general binaryGP function.

varargout = cell(nargout, 1);  % allocate the right number of output arguments
[varargout{:}] = binaryGP(hyper, 'approxEP', covfunc, 'cumGauss', varargin{:});
