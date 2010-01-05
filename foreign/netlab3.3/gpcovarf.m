function covf = gpcovarf(net, x1, x2)
%GPCOVARF Calculate the covariance function for a Gaussian Process.
%
%	Description
%
%	COVF = GPCOVARF(NET, X1, X2) takes  a Gaussian Process data structure
%	NET together with two matrices X1 and X2 of input vectors,  and
%	computes the matrix of the covariance function values COVF.
%
%	See also
%	GP, GPCOVAR, GPCOVARP, GPERR, GPGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

errstring = consist(net, 'gp', x1);
if ~isempty(errstring);
  error(errstring);
end

if size(x1, 2) ~= size(x2, 2)
  error('Number of variables in x1 and x2 must be the same');
end

n1 = size(x1, 1);
n2 = size(x2, 1);
beta = diag(exp(net.inweights));

% Compute the weighted squared distances between x1 and x2
z = (x1.*x1)*beta*ones(net.nin, n2) - 2*x1*beta*x2' ... 
  + ones(n1, net.nin)*beta*(x2.*x2)';

switch net.covar_fn

  case 'sqexp'		% Squared exponential
    covf = exp(net.fpar(1) - 0.5*z);

  case 'ratquad'	% Rational quadratic
    nu = exp(net.fpar(2));
    covf = exp(net.fpar(1))*((ones(size(z)) + z).^(-nu));

  otherwise
    error(['Unknown covariance function ', net.covar_fn]);  
end