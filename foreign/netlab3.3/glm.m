function net = glm(nin, nout, outfunc, prior, beta)
%GLM	Create a generalized linear model.
%
%	Description
%
%	NET = GLM(NIN, NOUT, FUNC) takes the number of inputs and outputs for
%	a generalized linear model, together with a string FUNC which
%	specifies the output unit activation function, and returns a data
%	structure NET. The weights are drawn from a zero mean, isotropic
%	Gaussian, with variance scaled by the fan-in of the output units.
%	This makes use of the Matlab function RANDN and so the seed for the
%	random weight initialization can be  set using RANDN('STATE', S)
%	where S is the seed value. The optional argument ALPHA sets the
%	inverse variance for the weight initialization.
%
%	The fields in NET are
%	  type = 'glm'
%	  nin = number of inputs
%	  nout = number of outputs
%	  nwts = total number of weights and biases
%	  actfn = string describing the output unit activation function:
%	      'linear'
%	      'logistic'
%	      'softmax'
%	  w1 = first-layer weight matrix
%	  b1 = first-layer bias vector
%
%	NET = GLM(NIN, NOUT, FUNC, PRIOR), in which PRIOR is a scalar, allows
%	the field  NET.ALPHA in the data structure NET to be set,
%	corresponding  to a zero-mean isotropic Gaussian prior with inverse
%	variance with value PRIOR. Alternatively, PRIOR can consist of a data
%	structure with fields ALPHA and INDEX, allowing individual Gaussian
%	priors to be set over groups of weights in the network. Here ALPHA is
%	a column vector in which each element corresponds to a  separate
%	group of weights, which need not be mutually exclusive.  The
%	membership of the groups is defined by the matrix INDEX in which the
%	columns correspond to the elements of ALPHA. Each column has one
%	element for each weight in the matrix, in the order defined by the
%	function GLMPAK, and each element is 1 or 0 according to whether the
%	weight is a member of the corresponding group or not.
%
%	NET = GLM(NIN, NOUT, FUNC, PRIOR, BETA) also sets the  additional
%	field NET.BETA in the data structure NET, where beta corresponds to
%	the inverse noise variance.
%
%	See also
%	GLMPAK, GLMUNPAK, GLMFWD, GLMERR, GLMGRAD, GLMTRAIN
%

%	Copyright (c) Ian T Nabney (1996-2001)

net.type = 'glm';
net.nin = nin;
net.nout = nout;
net.nwts = (nin + 1)*nout;

outtfns = {'linear', 'logistic', 'softmax'};

if sum(strcmp(outfunc, outtfns)) == 0
  error('Undefined activation function. Exiting.');
else
  net.outfn = outfunc;
end

if nargin > 3
  if isstruct(prior)
    net.alpha = prior.alpha;
    net.index = prior.index;
  elseif size(prior) == [1 1]
    net.alpha = prior;
  else
    error('prior must be a scalar or structure');
  end
end
  
net.w1 = randn(nin, nout)/sqrt(nin + 1);
net.b1 = randn(1, nout)/sqrt(nin + 1);

if nargin == 5
  net.beta = beta;
end

