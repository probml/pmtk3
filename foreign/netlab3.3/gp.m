function net = gp(nin, covar_fn, prior)
%GP	Create a Gaussian Process.
%
%	Description
%
%	NET = GP(NIN, COVARFN) takes the number of inputs NIN  for a Gaussian
%	Process model with a single output, together with a string COVARFN
%	which specifies the type of the covariance function, and returns a
%	data structure NET. The parameters are set to zero.
%
%	The fields in NET are
%	  type = 'gp'
%	  nin = number of inputs
%	  nout = number of outputs: always 1
%	  nwts = total number of weights and covariance function parameters
%	  bias = logarithm of constant offset in covariance function
%	  noise = logarithm of output noise variance
%	  inweights = logarithm of inverse length scale for each input 
%	  covarfn = string describing the covariance function:
%	      'sqexp'
%	      'ratquad'
%	  fpar = covariance function specific parameters (1 for squared exponential,
%	   2 for rational quadratic)
%	  trin = training input data (initially empty)
%	  trtargets = training target data (initially empty)
%
%	NET = GP(NIN, COVARFN, PRIOR) sets a Gaussian prior on the parameters
%	of the model. PRIOR must contain the fields PR_MEAN and PR_VARIANCE.
%	If PR_MEAN is a scalar, then the Gaussian is assumed to be isotropic
%	and the additional fields NET.PR_MEAN and PR_VARIANCE are set.
%	Otherwise,  the Gaussian prior has a mean defined by a column vector
%	of parameters PRIOR.PR_MEAN and covariance defined by a column vector
%	of parameters PRIOR.PR_VARIANCE. Each element of PRMEAN corresponds
%	to a separate group of parameters, which need not be mutually
%	exclusive. The membership of the groups is defined by the matrix
%	PRIOR.INDEX in which the columns correspond to the elements of
%	PRMEAN. Each column has one element for each weight in the matrix, in
%	the order defined by the function GPPAK, and each element is 1 or 0
%	according to whether the parameter is a member of the corresponding
%	group or not.  The additional field NET.INDEX is set in this case.
%
%	See also
%	GPPAK, GPUNPAK, GPFWD, GPERR, GPCOVAR, GPGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

net.type = 'gp';
net.nin = nin;
net.nout = 1;  % Only do single output GP

% Store log parameters
net.bias = 0;
net.min_noise = sqrt(eps);  % Prevent output noise collapsing completely
net.noise = 0;
net.inweights = zeros(1,nin);  % Weights on inputs in covariance function

covarfns = {'sqexp', 'ratquad'};

if sum(strcmp(covar_fn, covarfns)) == 0
  error('Undefined activation function. Exiting.');
else
  net.covar_fn = covar_fn;
end

switch covar_fn

  case 'sqexp'		% Squared exponential
    net.fpar = zeros(1,1);  % One function specific parameter
    
  case 'ratquad' 	% Rational quadratic
    net.fpar = zeros(1, 2); % Two function specific parameters

  otherwise
    error(['Unknown covariance function ', covar_fn]);
end

net.nwts = 2 + nin + length(net.fpar);

if nargin >= 3
  if size(prior.pr_mean) == [1 1]
    net.pr_mean = prior.pr_mean;
    net.pr_var = prior.pr_var;
  else
    net.pr_mean = prior.pr_mean;
    net.pr_var = prior.pr_var;
    net.index = prior.index;
  end  
end

% Store training data as needed for gpfwd
net.tr_in = [];
net.tr_targets = [];