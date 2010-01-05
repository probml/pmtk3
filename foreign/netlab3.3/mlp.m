function net = mlp(nin, nhidden, nout, outfunc, prior, beta)
%MLP	Create a 2-layer feedforward network.
%
%	Description
%	NET = MLP(NIN, NHIDDEN, NOUT, FUNC) takes the number of inputs,
%	hidden units and output units for a 2-layer feed-forward network,
%	together with a string FUNC which specifies the output unit
%	activation function, and returns a data structure NET. The weights
%	are drawn from a zero mean, unit variance isotropic Gaussian, with
%	varianced scaled by the fan-in of the hidden or output units as
%	appropriate. This makes use of the Matlab function RANDN and so the
%	seed for the random weight initialization can be  set using
%	RANDN('STATE', S) where S is the seed value.  The hidden units use
%	the TANH activation function.
%
%	The fields in NET are
%	  type = 'mlp'
%	  nin = number of inputs
%	  nhidden = number of hidden units
%	  nout = number of outputs
%	  nwts = total number of weights and biases
%	  actfn = string describing the output unit activation function:
%	      'linear'
%	      'logistic
%	      'softmax'
%	  w1 = first-layer weight matrix
%	  b1 = first-layer bias vector
%	  w2 = second-layer weight matrix
%	  b2 = second-layer bias vector
%	 Here W1 has dimensions NIN times NHIDDEN, B1 has dimensions 1 times
%	NHIDDEN, W2 has dimensions NHIDDEN times NOUT, and B2 has dimensions
%	1 times NOUT.
%
%	NET = MLP(NIN, NHIDDEN, NOUT, FUNC, PRIOR), in which PRIOR is a
%	scalar, allows the field NET.ALPHA in the data structure NET to be
%	set, corresponding to a zero-mean isotropic Gaussian prior with
%	inverse variance with value PRIOR. Alternatively, PRIOR can consist
%	of a data structure with fields ALPHA and INDEX, allowing individual
%	Gaussian priors to be set over groups of weights in the network. Here
%	ALPHA is a column vector in which each element corresponds to a
%	separate group of weights, which need not be mutually exclusive.  The
%	membership of the groups is defined by the matrix INDX in which the
%	columns correspond to the elements of ALPHA. Each column has one
%	element for each weight in the matrix, in the order defined by the
%	function MLPPAK, and each element is 1 or 0 according to whether the
%	weight is a member of the corresponding group or not. A utility
%	function MLPPRIOR is provided to help in setting up the PRIOR data
%	structure.
%
%	NET = MLP(NIN, NHIDDEN, NOUT, FUNC, PRIOR, BETA) also sets the
%	additional field NET.BETA in the data structure NET, where beta
%	corresponds to the inverse noise variance.
%
%	See also
%	MLPPRIOR, MLPPAK, MLPUNPAK, MLPFWD, MLPERR, MLPBKP, MLPGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

net.type = 'mlp';
net.nin = nin;
net.nhidden = nhidden;
net.nout = nout;
net.nwts = (nin + 1)*nhidden + (nhidden + 1)*nout;

outfns = {'linear', 'logistic', 'softmax'};

if sum(strcmp(outfunc, outfns)) == 0
  error('Undefined output function. Exiting.');
else
  net.outfn = outfunc;
end

if nargin > 4
  if isstruct(prior)
    net.alpha = prior.alpha;
    net.index = prior.index;
  elseif size(prior) == [1 1]
    net.alpha = prior;
  else
    error('prior must be a scalar or a structure');
  end  
end

net.w1 = randn(nin, nhidden)/sqrt(nin + 1);
net.b1 = randn(1, nhidden)/sqrt(nin + 1);
net.w2 = randn(nhidden, nout)/sqrt(nhidden + 1);
net.b2 = randn(1, nout)/sqrt(nhidden + 1);

if nargin == 6
  net.beta = beta;
end
