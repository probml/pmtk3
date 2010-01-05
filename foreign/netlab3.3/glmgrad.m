function [g, gdata, gprior] = glmgrad(net, x, t)
%GLMGRAD Evaluate gradient of error function for generalized linear model.
%
%	Description
%	G = GLMGRAD(NET, X, T) takes a generalized linear model data
%	structure NET  together with a matrix X of input vectors and a matrix
%	T of target vectors, and evaluates the gradient G of the error
%	function with respect to the network weights. The error function
%	corresponds to the choice of output unit activation function. Each
%	row of X corresponds to one input vector and each row of T
%	corresponds to one target vector.
%
%	[G, GDATA, GPRIOR] = GLMGRAD(NET, X, T) also returns separately  the
%	data and prior contributions to the gradient.
%
%	See also
%	GLM, GLMPAK, GLMUNPAK, GLMFWD, GLMERR, GLMTRAIN
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'glm', x, t);
if ~isempty(errstring);
  error(errstring);
end

y = glmfwd(net, x);
delout = y - t;

gw1 = x'*delout;
gb1 = sum(delout, 1);

gdata = [gw1(:)', gb1];

[g, gdata, gprior] = gbayes(net, gdata);
