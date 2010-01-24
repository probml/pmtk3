% covariance functions to be use by Gaussian process functions. There are two
% different kinds of covariance functions: simple and composite:
%
% simple covariance functions:
%
%   covConst.m      - covariance for constant functions
%   covLINard.m     - linear covariance function with ard
%   covLINone.m     - linear covariance function
%   covMatern3iso.m - Matern covariance function with nu=3/2
%   covMatern5iso.m - Matern covariance function with nu=5/2
%   covNNone.m      - neural network covariance function
%   covNoise.m      - independent covariance function (ie white noise)
%   covPeriodic.m   - covariance for smooth periodic function with unit period
%   covRQard.m      - rational quadratic covariance function with ard 
%   covRQiso.m      - isotropic rational quadratic covariance function
%   covSEard.m      - squared exponential covariance function with ard
%   covSEiso.m      - isotropic squared exponential covariance function
% 
% composite covariance functions (see explanation at the bottom):
%
%   covProd         - products of covariance functions
%   covSum          - sums of covariance functions
%
% Naming convention: all covariance functions start with "cov". A trailing
% "iso" means isotropic, "ard" means Automatic Relevance Determination, and
% "one" means that the distance measure is parameterized by a single parameter.
%
% The covariance functions are written according to a special convention where
% the exact behaviour depends on the number of input and output arguments
% passed to the function. If you want to add new covariance functions, you 
% should follow this convention if you want them to work with the functions
% gpr, binaryEPGP and binaryLaplaceGP. There are four different ways of calling
% the covariance functions:
%
% 1) With no input arguments:
%
%    p = covNAME
%
% The covariance function returns a string telling how many hyperparameters it
% expects, using the convention that "D" is the dimension of the input space.
% For example, calling "covRQard" returns the string '(D+2)'.
%
% 2) With two input arguments:
%
%    K = covNAME(logtheta, x) 
%
% The function computes and returns the covariance matrix where logtheta are
% the log og the hyperparameters and x is an n by D matrix of cases, where
% D is the dimension of the input space. The returned covariance matrix is of
% size n by n.
%
% 3) With three input arguments and two output arguments:
%
%    [v, B] = covNAME(loghyper, x, z)
%
% The function computes test set covariances; v is a vector of self covariances
% for the test cases in z (of length nn) and B is a (n by nn) matrix of cross
% covariances between training cases x and test cases z.
%
% 4) With three input arguments and a single output:
%
%     D = covNAME(logtheta, x, z)
%
% The function computes and returns the n by n matrix of partial derivatives
% of the training set covariance matrix with respect to logtheta(z), ie with
% respect to the log of hyperparameter number z.
%
% The functions may retain a local copy of the covariance matrix for computing
% derivatives, which is cleared as the last derivative is returned.
%
% About the specification of simple and composite covariance functions to be
% used by the Gaussian process functions gpr, binaryEPGP and binaryLaplaceGP:
% Covariance functions can be specified in two ways: either as a string
% containing the name of the covariance function or using a cell array. For
% example:
%
%   covfunc = 'covRQard';
%   covfunc = {'covRQard'};
%
% are both supported. Only the second form using the cell array can be used
% for specifying composite covariance functions, made up of several
% contributions. For example:
%
%   covfunc = {'covSum',{'covRQiso','covSEard','covNoise'}};
%
% specifies a covariance function which is the sum of three contributions. To 
% find out how many hyperparameters this covariance function requires, we do:
%
%   feval(covfunc{:})
% 
% which returns the string '3+(D+1)+1' (ie the 'covRQiso' contribution uses
% 3 parameters, the 'covSEard' uses D+1 and 'covNoise' a single parameter).
%
% (C) copyright 2006, Carl Edward Rasmussen, 2006-04-07.

