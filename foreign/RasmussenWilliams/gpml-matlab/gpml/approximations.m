% approximations: Exact inference for Gaussian process classification is
% intractable, and approximations are necessary. Different approximation
% techniques have been implemented, which all rely on a Gaussian approximation
% to the non-Gaussian posterior:
%
%   approxEP   the Expectation Propagation (EP) algorithm 
%   approxLA   Laplace's method
%
% which are used by the Gaussian process classification funtion binaryGP.m.
% The interface to the approximation methods is the following:
%
%   function [alpha, sW, L, nlZ, dnlZ] = approx..(hyper, covfunc, lik, x, y)
%
% where:
%
%   hyper    is a column vector of hyperparameters
%   covfunc  is the name of the covariance function (see covFunctions.m)
%   lik      is the name of the likelihood function (see likelihoods.m)
%   x        is a n by D matrix of training inputs 
%   y        is a (column) vector (of size n) of binary +1/-1 targets
%   nlZ      is the returned value of the negative log marginal likelihood
%   dnlZ     is a (column) vector of partial derivatives of the negative
%               log marginal likelihood wrt each hyperparameter
%   alpha    is a (sparse or full column vector) containing inv(K)*m, where K
%               is the prior covariance matrix and m the approx posterior mean
%   sW       is a (sparse or full column) vector containing diagonal of sqrt(W)
%               the approximate posterior covariance matrix is inv(inv(K)+W)
%   L        is a (sparse or full) matrix, L = chol(sW*K*sW+eye(n))
%
% Usually, the approximate posterior to be returned admits the form
% N(m=K*alpha, V=inv(inv(K)+W)), where alpha is a vector and W is diagonal;
% if not, then L contains instead -inv(K+inv(W)), and sW is unused.
%
% For more information on the individual approximation methods and their
% implementations, see the separate approx??.m files. See also binaryGP.m
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2007-06-25.

