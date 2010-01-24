function [mu, S2SR, S2PP] = gprSRPP(logtheta, covfunc, x, INDEX, y, xstar);

% gprSRPP - Carries out approximate Gaussian process regression prediction
% using the subset of regressors (SR) or projected process approximation (PP)
% and the active set specified by INDEX.
%
% Usage
%
%   [mu, S2SR, S2PP] = gprSRPP(logtheta, covfunc, x, INDEX, y, xstar)
%
% where
%
%   logtheta is a (column) vector of log hyperparameters
%   covfunc  is the covariance function, which is assumed to
%            be a covSum, and the last entry of the sum is covNoise
%   x        is a n by D matrix of training inputs
%   INDEX    is a vector of length m <= n used to specify which 
%            inputs are used in the active set 
%   y        is a (column) vector (of size n) of targets
%   xstar    is a nstar by D matrix of test inputs
%   mu       is a (column) vector (of size nstar) of prediced means
%   S2SR  is a (column) vector (of size nstar) of predicted variances under SR
%   S2PP  is a (column) vector (of size nsstar) of predicted variances under PP
%
% where D is the dimension of the input.
%
% For more help on covariance functions, see "help covFunctions".
%
% (C) copyright 2005, 2006 by Chris Williams (2006-03-29).

if ischar(covfunc), covfunc = cellstr(covfunc); end % convert to cell if needed
[n, D] = size(x);
if eval(feval(covfunc{:})) ~= size(logtheta, 1)
  error('Error: Number of parameters do not agree with covariance function')
end

% we check that the covfunc cell array is a covSum, with last entry 'covNoise'
if length(covfunc) ~= 2 | ~strcmp(covfunc(1), 'covSum') | ...
                                           ~strcmp(covfunc{2}(end), 'covNoise')
  error('The covfunc must be "covSum" whose last summand must be "covNoise"')
end

sigma2n = exp(2*logtheta(end));                                % noise variance
[nstar, D] = size(xstar);   % number of test cases and dimension of input space
m = length(INDEX);                                             % size of subset

% note, that in the following Kmm is computed by extracting the relevant part
% of Knm, thus it will be the "noise-free" covariance (although the covfunc
% specification does include noise).

[v, Knm] = feval(covfunc{:}, logtheta, x, x(INDEX,:));   
Kmm = Knm(INDEX,:);                     % Kmm is a noise-free covariance matrix
jitter = 1e-9*trace(Kmm);
Kmm = Kmm + jitter*eye(m);                        % as suggested in code of jqc

% a is cov between active set and test points and vstar is variances at test
% points, incl noise variance

[vstar, a] = feval(covfunc{:}, logtheta, x(INDEX,:), xstar);   

mu = a'*((sigma2n*Kmm + Knm'*Knm)\(Knm'*y));  % pred mean eq. (8.14) and (8.26)

e = (sigma2n*Kmm + Knm'*Knm) \ a;

S2SR = sigma2n*sum(a.*e,1)';                 % noise-free SR variance, eq. 8.15
S2PP = vstar-sum(a.*(Kmm\a),1)'+S2SR;  % PP variance eq. (8.27) including noise
S2SR = S2SR + sigma2n;                            % SR variance inclusing noise

