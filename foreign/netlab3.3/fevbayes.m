function [extra, invhess] = fevbayes(net, y, a, x, t, x_test, invhess)
%FEVBAYES Evaluate Bayesian regularisation for network forward propagation.
%
%	Description
%	EXTRA = FEVBAYES(NET, Y, A, X, T, X_TEST) takes a network data
%	structure  NET together with a set of hidden unit activations A from
%	test inputs X_TEST, training data inputs X and T and outputs a matrix
%	of extra information EXTRA that consists of error bars (variance) for
%	a regression problem or moderated outputs for a classification
%	problem. The optional argument (and return value)  INVHESS is the
%	inverse of the network Hessian computed on the training data inputs
%	and targets.  Passing it in avoids recomputing it, which can be a
%	significant saving for large training sets.
%
%	This is called by network-specific functions such as MLPEVFWD which
%	are needed since the return values (predictions and hidden unit
%	activations) for different network types are in different orders (for
%	good reasons).
%
%	See also
%	MLPEVFWD, RBFEVFWD, GLMEVFWD
%

%	Copyright (c) Ian T Nabney (1996-2001)

w = netpak(net);
g = netderiv(w, net, x_test);
if nargin < 7
  % Need to compute inverse hessian
  hess = nethess(w, net, x, t);
  invhess = inv(hess);
end

ntest = size(x_test, 1);
var = zeros(ntest, 1);
for idx = 1:1:net.nout,
  for n = 1:1:ntest,
    grad = squeeze(g(n,:,idx));
    var(n,idx) = grad*invhess*grad';  
  end
end

switch net.outfn
    case 'linear'
	% extra is variance
	extra = ones(size(var))./net.beta + var;
    case 'logistic'
	% extra is moderated output
	kappa = 1./(sqrt(ones(size(var)) + (pi.*var)./8));
	extra = 1./(1 + exp(-kappa.*a));
    case 'softmax'
	% Use extended Mackay formula; beware that this may not
	% be very accurate
	kappa = 1./(sqrt(ones(size(var)) + (pi.*var)./8));
	temp = exp(kappa.*a);
	extra = temp./(sum(temp, 2)*ones(1, net.nout));
    otherwise
	error(['Unknown activation function ', net.outfn]);
end
