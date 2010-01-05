function [net, options, varargout] = netopt(net, options, x, t, alg);
%NETOPT	Optimize the weights in a network model. 
%
%	Description
%
%	NETOPT is a helper function which facilitates the training of
%	networks using the general purpose optimizers as well as sampling
%	from the posterior distribution of parameters using general purpose
%	Markov chain Monte Carlo sampling algorithms. It can be used with any
%	function that searches in parameter space using error and gradient
%	functions.
%
%	[NET, OPTIONS] = NETOPT(NET, OPTIONS, X, T, ALG) takes a network
%	data structure NET, together with a vector OPTIONS of parameters
%	governing the behaviour of the optimization algorithm, a matrix X of
%	input vectors and a matrix T of target vectors, and returns the
%	trained network as well as an updated OPTIONS vector. The string ALG
%	determines which optimization algorithm (CONJGRAD, QUASINEW, SCG,
%	etc.) or Monte Carlo algorithm (such as HMC) will be used.
%
%	[NET, OPTIONS, VARARGOUT] = NETOPT(NET, OPTIONS, X, T, ALG) also
%	returns any additional return values from the optimisation algorithm.
%
%	See also
%	NETGRAD, BFGS, CONJGRAD, GRADDESC, HMC, SCG
%

%	Copyright (c) Ian T Nabney (1996-2001)

optstring = [alg, '(''neterr'', w, options, ''netgrad'', net, x, t)'];

% Extract weights from network as single vector
w = netpak(net);

% Carry out optimisation
[s{1:nargout}] = eval(optstring);
w = s{1};

if nargout > 1
  options = s{2};

  % If there are additional arguments, extract them
  nextra = nargout - 2;
  if nextra > 0
    for i = 1:nextra
      varargout{i} = s{i+2};
    end
  end
end

% Pack the weights back into the network
net = netunpak(net, w);
