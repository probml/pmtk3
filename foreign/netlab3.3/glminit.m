function net = glminit(net, prior)
%GLMINIT Initialise the weights in a generalized linear model.
%
%	Description
%
%	NET = GLMINIT(NET, PRIOR) takes a generalized linear model NET and
%	sets the weights and biases by sampling from a Gaussian distribution.
%	If PRIOR is a scalar, then all of the parameters (weights and biases)
%	are sampled from a single isotropic Gaussian with inverse variance
%	equal to PRIOR. If PRIOR is a data structure similar to that in
%	MLPPRIOR but for a single layer of weights, then the parameters are
%	sampled from multiple Gaussians according to their groupings (defined
%	by the INDEX field) with corresponding variances (defined by the
%	ALPHA field).
%
%	See also
%	GLM, GLMPAK, GLMUNPAK, MLPINIT, MLPPRIOR
%

%	Copyright (c) Ian T Nabney (1996-2001)

errstring = consist(net, 'glm');
if ~isempty(errstring);
  error(errstring);
end
if isstruct(prior)
  sig = 1./sqrt(prior.index*prior.alpha);
  w = sig'.*randn(1, net.nwts); 
elseif size(prior) == [1 1]
  w = randn(1, net.nwts).*sqrt(1/prior);
else
  error('prior must be a scalar or a structure');
end  

net = glmunpak(net, w);

