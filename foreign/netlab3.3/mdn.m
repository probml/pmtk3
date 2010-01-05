function net = mdn(nin, nhidden, ncentres, dim_target, mix_type, ...
	prior, beta)
%MDN	Creates a Mixture Density Network with specified architecture.
%
%	Description
%	NET = MDN(NIN, NHIDDEN, NCENTRES, DIMTARGET) takes the number of
%	inputs,  hidden units for a 2-layer feed-forward  network and the
%	number of centres and target dimension for the  mixture model whose
%	parameters are set from the outputs of the neural network. The fifth
%	argument MIXTYPE is used to define the type of mixture model.
%	(Currently there is only one type supported: a mixture of Gaussians
%	with a single covariance parameter for each component.) For this
%	model, the mixture coefficients are computed from a group of softmax
%	outputs, the centres are equal to a group of linear outputs, and the
%	variances are  obtained by applying the exponential function to a
%	third group of outputs.
%
%	The network is initialised by a call to MLP, and the arguments PRIOR,
%	and BETA have the same role as for that function. Weight
%	initialisation uses the Matlab function RANDN  and so the seed for
%	the random weight initialization can be  set using RANDN('STATE', S)
%	where S is the seed value. A specialised data structure (rather than
%	GMM) is used for the mixture model outputs to improve the efficiency
%	of error and gradient calculations in network training. The fields
%	are described in MDNFWD where they are set up.
%
%	The fields in NET are
%	  
%	  type = 'mdn'
%	  nin = number of input variables
%	  nout = dimension of target space (not number of network outputs)
%	  nwts = total number of weights and biases
%	  mdnmixes = data structure for mixture model output
%	  mlp = data structure for MLP network
%
%	See also
%	MDNFWD, MDNERR, MDN2GMM, MDNGRAD, MDNPAK, MDNUNPAK, MLP
%

%	Copyright (c) Ian T Nabney (1996-2001)
%	David J Evans (1998)

% Currently ignore type argument: reserved for future use
net.type = 'mdn';

% Set up the mixture model part of the structure
% For efficiency we use a specialised data structure in place of GMM
mdnmixes.type = 'mdnmixes';
mdnmixes.ncentres = ncentres;
mdnmixes.dim_target = dim_target;

% This calculation depends on spherical variances
mdnmixes.nparams = ncentres + ncentres*dim_target + ncentres;

% Make the weights in the mdnmixes structure null 
mdnmixes.mixcoeffs = [];
mdnmixes.centres = [];
mdnmixes.covars = [];

% Number of output nodes = number of parameters in mixture model
nout = mdnmixes.nparams;

% Set up the MLP part of the network
if (nargin == 5)
  mlpnet = mlp(nin, nhidden, nout, 'linear');
elseif (nargin == 6)
  mlpnet = mlp(nin, nhidden, nout, 'linear', prior);
elseif (nargin == 7)
  mlpnet = mlp(nin, nhidden, nout, 'linear', prior, beta);
end

% Create descriptor
net.mdnmixes = mdnmixes;
net.mlp = mlpnet;
net.nin = nin;
net.nout = dim_target;
net.nwts = mlpnet.nwts;
