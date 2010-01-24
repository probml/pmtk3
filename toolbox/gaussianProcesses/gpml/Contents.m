% gpml: code from Rasmussen & Williams: Gaussian Processes for Machine Learning
% date: 2007-07-25.
% 
% approxEP.m        - the approximation method for Expectation Propagation
% approxLA.m        - the approximation method for Laplace's approximation
% approximations.m  - help for approximation methods
% binaryEPGP.m      - outdated, the EP approx for binary GP classification
% binaryGP.m        - binary Gaussian process classification
% binaryLaplaceGP.m - outdated, Laplace's approx for binary GP classification
%
%   covConst.m      - covariance for constant functions
%   covFunctions.m  - help file with overview of covariance functions
%   covLINard.m     - linear covariance function with ard
%   covLINone.m     - linear covaraince function
%   covMatern3iso.m - Matern covariance function with nu=3/2
%   covMatern5iso.m - Matern covaraince function with nu=5/2
%   covNNone.m      - neural network covariance function
%   covNoise.m      - independent covaraince function (ie white noise)
%   covPeriodic.m   - covariance for smooth periodic function, with unit period
%   covProd.m       - function for multiplying other covariance functions
%   covRQard.m      - rational quadratic covariance function with ard 
%   covRQiso.m      - isotropic rational quadratic covariance function
%   covSEard.m      - squared exponential covariance function with ard
%   covSEiso.m      - isotropic squared exponential covariance function
%   covSum.m        - function for adding other covariance functions
%
% cumGauss.m        - cumulative Gaussian likelihood function
% gpr.m             - Gaussian process regression with general covariance
%                     function 
% gprSRPP.m         - Implements SR and PP approximations to GPR
% likelihoods.m     - help function for classification likelihoods
% logistic.m        - logistic likelihood function
% minimize.m        - Minimize a differentiable multivariate function
% solve_chol.c      - Solve linear equations from the Cholesky factorization
%                     should be compiled into a mex file
% solve_chol.m      - A matlab implementation of the above, used only in case
%                     the mex file wasn't generated (not very efficient)
% sq_dist.c         - Compute a matrix of all pairwise squared distances
%                     should be compiled into a mex file
% sq_dist.m         - A matlab implementation of the above, used only in case
%                     the mex file wasn't generated (not very efficient)
% 
% See also the help for the demonstration scripts in the gpml-demo directory
%
% Copyright (c) 2005, 2006 by Carl Edward Rasmussen and Chris Williams

