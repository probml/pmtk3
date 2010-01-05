function [mixparams, y, z, a] = mdnfwd(net, x)
%MDNFWD	Forward propagation through Mixture Density Network.
%
%	Description
%	 MIXPARAMS = MDNFWD(NET, X) takes a mixture density network data
%	structure NET and a matrix X of input vectors, and forward propagates
%	the inputs through the network to generate a structure MIXPARAMS
%	which contains the parameters of several mixture models.   Each row
%	of X represents one input vector and the corresponding row of the
%	matrices in MIXPARAMS  represents the parameters of a mixture model
%	for the conditional probability of target vectors given the input
%	vector.  This is not represented as an array of GMM structures to
%	improve the efficiency of MDN training.
%
%	The fields in MIXPARAMS are
%	  type = 'mdnmixes'
%	  ncentres = number of mixture components
%	  dimtarget = dimension of target space
%	  mixcoeffs = mixing coefficients
%	  centres = means of Gaussians: stored as one row per pattern
%	  covars = covariances of Gaussians
%	  nparams = number of parameters
%
%	[MIXPARAMS, Y, Z] = MDNFWD(NET, X) also generates a matrix Y of the
%	outputs of the MLP and a matrix Z of the hidden unit activations
%	where each row corresponds to one pattern.
%
%	[MIXPARAMS, Y, Z, A] = MLPFWD(NET, X) also returns a matrix A  giving
%	the summed inputs to each output unit, where each row  corresponds to
%	one pattern.
%
%	See also
%	MDN, MDN2GMM, MDNERR, MDNGRAD, MLPFWD
%

%	Copyright (c) Ian T Nabney (1996-2001)
%	David J Evans (1998)

% Check arguments for consistency
errstring = consist(net, 'mdn', x);
if ~isempty(errstring)
  error(errstring);
end

% Extract mlp and mixture model descriptors
mlpnet = net.mlp;
mixes = net.mdnmixes;

ncentres = mixes.ncentres;	% Number of components in mixture model
dim_target = mixes.dim_target;	% Dimension of targets
nparams = mixes.nparams;	% Number of parameters in mixture model

% Propagate forwards through MLP
[y, z, a] = mlpfwd(mlpnet, x);

% Compute the postion for each parameter in the whole
% matrix.  Used to define the mixparams structure
mixcoeff  = [1:1:ncentres];
centres   = [ncentres+1:1:(ncentres*(1+dim_target))];
variances = [(ncentres*(1+dim_target)+1):1:nparams];

% Convert output values into mixture model parameters

% Use softmax to calculate priors
% Prevent overflow and underflow: use same bounds as glmfwd
% Ensure that sum(exp(y), 2) does not overflow
maxcut = log(realmax) - log(ncentres);
% Ensure that exp(y) > 0
mincut = log(realmin);
temp = min(y(:,1:ncentres), maxcut);
temp = max(temp, mincut);
temp = exp(temp);
mixpriors = temp./(sum(temp, 2)*ones(1,ncentres));

% Centres are just copies of network outputs
mixcentres =  y(:,(ncentres+1):ncentres*(1+dim_target));

% Variances are exp of network outputs
mixwidths = exp(y(:,(ncentres*(1+dim_target)+1):nparams));

% Now build up all the mixture model weight vectors
ndata = size(x, 1);

% Return parameters
mixparams.type = mixes.type;
mixparams.ncentres = mixes.ncentres;
mixparams.dim_target = mixes.dim_target;
mixparams.nparams = mixes.nparams;

mixparams.mixcoeffs = mixpriors;
mixparams.centres   = mixcentres;
mixparams.covars      = mixwidths;

