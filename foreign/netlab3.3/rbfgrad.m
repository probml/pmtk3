function [g, gdata, gprior] = rbfgrad(net, x, t)
%RBFGRAD Evaluate gradient of error function for RBF network.
%
%	Description
%	G = RBFGRAD(NET, X, T) takes a network data structure NET together
%	with a matrix X of input vectors and a matrix T of target vectors,
%	and evaluates the gradient G of the error function with respect to
%	the network weights (i.e. including the hidden unit parameters). The
%	error function is sum of squares. Each row of X corresponds to one
%	input vector and each row of T contains the corresponding target
%	vector. If the output function is 'NEUROSCALE' then the gradient is
%	only computed for the output layer weights and biases.
%
%	[G, GDATA, GPRIOR] = RBFGRAD(NET, X, T) also returns separately  the
%	data and prior contributions to the gradient. In the case of multiple
%	groups in the prior, GPRIOR is a matrix with a row for each group and
%	a column for each weight parameter.
%
%	See also
%	RBF, RBFFWD, RBFERR, RBFPAK, RBFUNPAK, RBFBKP
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
switch net.outfn
case 'linear'
   errstring = consist(net, 'rbf', x, t);
case 'neuroscale'
   errstring = consist(net, 'rbf', x);
otherwise
   error(['Unknown output function ', net.outfn]);
end
if ~isempty(errstring);
  error(errstring);
end

ndata = size(x, 1);

[y, z, n2] = rbffwd(net, x);

switch net.outfn
case 'linear'

   % Sum squared error at output units
   delout = y - t;

   gdata = rbfbkp(net, x, z, n2, delout);
   [g, gdata, gprior] = gbayes(net, gdata);

case 'neuroscale'
   % Compute the error gradient with respect to outputs
   y_dist = sqrt(dist2(y, y));
   D = (t - y_dist)./(y_dist+diag(ones(ndata, 1)));
   temp = y';
   gradient = 2.*sum(kron(D, ones(1, net.nout)) .* ...
      (repmat(y, 1, ndata) - repmat((temp(:))', ndata, 1)), 1);
   gradient = (reshape(gradient, net.nout, ndata))';
   % Compute the error gradient
   gdata = rbfbkp(net, x, z, n2, gradient);
   [g, gdata, gprior] = gbayes(net, gdata);
otherwise
   error(['Unknown output function ', net.outfn]);
end

