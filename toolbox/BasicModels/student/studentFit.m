function [model] = studentFit(X, dof)
% Fit multivariate student T distribution 
% X(i,:) is i'th case
% If dof is unknown, set it to [].
% model  is a structure containing fields: mu, Sigma, dof
% For a scalar distribution, Sigma is the variance
% default algorithm is EM

% This file is from pmtk3.googlecode.com

if nargin < 2, dof = []; end
model = studentFitEm(X, 'dof', dof);

end
