function [mask, prior] = rbfprior(rbfunc, nin, nhidden, nout, aw2, ab2)
%RBFPRIOR Create Gaussian prior and output layer mask for RBF.
%
%	Description
%	[MASK, PRIOR] = RBFPRIOR(RBFUNC, NIN, NHIDDEN, NOUT, AW2, AB2)
%	generates a vector MASK  that selects only the output layer weights.
%	This is because most uses of RBF networks in a Bayesian context have
%	fixed basis functions with the output layer as the only adjustable
%	parameters.  In particular, the Neuroscale output error function is
%	designed to work only with this mask.
%
%	The return value PRIOR is a data structure,  with fields PRIOR.ALPHA
%	and PRIOR.INDEX, which specifies a Gaussian prior distribution for
%	the network weights in an RBF network. The parameters AW2 and AB2 are
%	all scalars and represent the regularization coefficients for two
%	groups of parameters in the network corresponding to  second-layer
%	weights, and second-layer biases respectively. Then PRIOR.ALPHA
%	represents a column vector of length 2 containing the parameters, and
%	PRIOR.INDEX is a matrix specifying which weights belong in each
%	group. Each column has one element for each weight in the matrix,
%	using the standard ordering as defined in RBFPAK, and each element is
%	1 or 0 according to whether the weight is a member of the
%	corresponding group or not.
%
%	See also
%	RBF, RBFERR, RBFGRAD, EVIDENCE
%

%	Copyright (c) Ian T Nabney (1996-2001)

nwts_layer2 = nout + (nhidden *nout);
switch rbfunc
case 'gaussian'
   nwts_layer1 = nin*nhidden + nhidden;
case {'tps', 'r4logr'}
   nwts_layer1 = nin*nhidden;
otherwise
   error('Undefined activation function');
end  
nwts = nwts_layer1 + nwts_layer2;

% Make a mask only for output layer
mask = [zeros(nwts_layer1, 1); ones(nwts_layer2, 1)];

if nargout > 1
  % Construct prior
  indx = zeros(nwts, 2);
  mark2 = nwts_layer1 + (nhidden * nout);
  indx(nwts_layer1 + 1:mark2, 1) = ones(nhidden * nout, 1);
  indx(mark2 + 1:nwts, 2) = ones(nout, 1);

  prior.index = indx;
  prior.alpha = [aw2, ab2]';
end