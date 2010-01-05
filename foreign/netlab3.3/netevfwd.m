function [y, extra, invhess] = netevfwd(w, net, x, t, x_test, invhess)
%NETEVFWD Generic forward propagation with evidence for network
%
%	Description
%	[Y, EXTRA] = NETEVFWD(W, NET, X, T, X_TEST) takes a network data
%	structure  NET together with the input X and target T training data
%	and input test data X_TEST. It returns the normal forward propagation
%	through the network Y together with a matrix EXTRA which consists of
%	error bars (variance) for a regression problem or moderated outputs
%	for a classification problem.
%
%	The optional argument (and return value)  INVHESS is the inverse of
%	the network Hessian computed on the training data inputs and targets.
%	Passing it in avoids recomputing it, which can be a significant
%	saving for large training sets.
%
%	See also
%	MLPEVFWD, RBFEVFWD, GLMEVFWD, FEVBAYES
%

%	Copyright (c) Ian T Nabney (1996-2001)

func = [net.type, 'evfwd'];
net = netunpak(net, w);
if nargin == 5
  [y, extra, invhess] = feval(func, net, x, t, x_test);
else
  [y, extra, invhess] = feval(func, net, x, t, x_test, invhess);
end
