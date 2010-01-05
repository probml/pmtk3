function p = normpdf(varargin)
%NORMPDF    Multivariate normal probability density function.
% NORMPDF(x) returns a row vector giving the density at each column of x 
%   under a standard multivariate normal.
% NORMPDF(x,m) subtracts m from x first.  
%   If cols(m) == 1, subtracts m from each column of x.
%   If cols(m) == cols(x), subtracts corresponding columns.
%   If cols(x) == 1, x is repeated to match cols(m).
% NORMPDF(x,m,S) specifies the standard deviation, or more generally
%   an upper triangular Cholesky factor of the covariance matrix.
%   In the univariate case, multiple standard deviations can be specified.
%   If m is empty, no subtraction is done (zero mean).
% NORMPDF(x,m,[],V) specifies the variance or covariance matrix.
% NORMPDF(x,m,'inv',iV) specifies the inverse of the covariance matrix, i.e.
%   the precision matrix.
% NORMPDF(x,m,iS,'inv') specifies the reciprocal of the standard deviation,
%   or more generally the upper triangular Cholesky factor of the
%   inverse covariance matrix.
%   This is the most efficient option.
% See test_normpdf for a timing test.

% this may look strange, but computing normpdf directly is no faster or
% more stable than exp(normpdfln).
p = exp(normpdfln(varargin{:}));
