function [y, extra, invhess] = glmevfwd(net, x, t, x_test, invhess)
%GLMEVFWD Forward propagation with evidence for GLM
%
%	Description
%	Y = GLMEVFWD(NET, X, T, X_TEST) takes a network data structure  NET
%	together with the input X and target T training data and input test
%	data X_TEST. It returns the normal forward propagation through the
%	network Y together with a matrix EXTRA which consists of error bars
%	(variance) for a regression problem or moderated outputs for a
%	classification problem.
%
%	The optional argument (and return value)  INVHESS is the inverse of
%	the network Hessian computed on the training data inputs and targets.
%	Passing it in avoids recomputing it, which can be a significant
%	saving for large training sets.
%
%	See also
%	FEVBAYES
%

%	Copyright (c) Ian T Nabney (1996-2001)

[y, a] = glmfwd(net, x_test);
if nargin == 4
  [extra, invhess] = fevbayes(net, y, a, x, t, x_test);
else
  [extra, invhess] = fevbayes(net, y, a, x, t, x_test, invhess);
end
