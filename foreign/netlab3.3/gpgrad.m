function g = gpgrad(net, x, t)
%GPGRAD	Evaluate error gradient for Gaussian Process.
%
%	Description
%	G = GPGRAD(NET, X, T) takes a Gaussian Process data structure NET
%	together  with a matrix X of input vectors and a matrix T of target
%	vectors, and evaluates the error gradient G. Each row of X
%	corresponds to one input vector and each row of T corresponds to one
%	target vector.
%
%	See also
%	GP, GPCOVAR, GPFWD, GPERR
%

%	Copyright (c) Ian T Nabney (1996-2001)

errstring = consist(net, 'gp', x, t);
if ~isempty(errstring);
  error(errstring);
end

% Evaluate derivatives with respect to each hyperparameter in turn.
ndata = size(x, 1);
[cov, covf] = gpcovar(net, x);
cninv = inv(cov);
trcninv = trace(cninv);
cninvt = cninv*t;

% Function parameters
switch net.covar_fn

  case 'sqexp'		% Squared exponential
    gfpar = trace(cninv*covf) - cninvt'*covf*cninvt;

  case 'ratquad' 	% Rational quadratic
    beta = diag(exp(net.inweights));
    gfpar(1) = trace(cninv*covf) - cninvt'*covf*cninvt;
    D2 = (x.*x)*beta*ones(net.nin, ndata) - 2*x*beta*x' ... 
      + ones(ndata, net.nin)*beta*(x.*x)';
    E = ones(size(D2));
    L = - exp(net.fpar(2)) * covf .* log(E + D2); % d(cn)/d(nu)
    gfpar(2) = trace(cninv*L) - cninvt'*L*cninvt;

  otherwise
    error(['Unknown covariance function ', net.covar_fn]);
end

% Bias derivative
ndata = size(x, 1);
fac = exp(net.bias)*ones(ndata);
gbias = trace(cninv*fac) - cninvt'*fac*cninvt;

% Noise derivative
gnoise = exp(net.noise)*(trcninv - cninvt'*cninvt);

% Input weight derivatives
if strcmp(net.covar_fn, 'ratquad')
  F = (exp(net.fpar(2))*E)./(E + D2);
end

nparams = length(net.inweights);
for l = 1 : nparams
  vect = x(:, l);
  matx = (vect.*vect)*ones(1, ndata) ... 
	- 2.0*vect*vect' ... 
	+ ones(ndata, 1)*(vect.*vect)';
  switch net.covar_fn
    case 'sqexp'	% Squared exponential
      dmat = -0.5*exp(net.inweights(l))*covf.*matx;
      
    case 'ratquad'	% Rational quadratic
      dmat = - exp(net.inweights(l))*covf.*matx.*F;
    otherwise
      error(['Unknown covariance function ', net.covar_fn]);
  end

  gw1(l) = trace(cninv*dmat) - cninvt'*dmat*cninvt;
end

g1 = [gbias, gnoise, gw1, gfpar];
g1 = 0.5*g1;

% Evaluate the prior contribution to the gradient.
if isfield(net, 'pr_mean')
  w = gppak(net);
  m = repmat(net.pr_mean, size(w));
  if size(net.pr_mean) == [1 1]
    gprior = w - m;
    g2 = gprior/net.pr_var;
  else
    ngroups = size(net.pr_mean, 1);
    gprior = net.index'.*(ones(ngroups, 1)*w - m);
    g2 = (1./net.pr_var)'*gprior;
  end
else
  gprior = 0;
  g2 = 0;
end

g = g1 + g2;
