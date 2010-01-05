function g = netderiv(w, net, x)
%NETDERIV Evaluate derivatives of network outputs by weights generically.
%
%	Description
%
%	G = NETDERIV(W, NET, X) takes a weight vector W and a network data
%	structure NET, together with the matrix X of input vectors, and
%	returns the gradient of the outputs with respect to the weights
%	evaluated at W.
%
%	See also
%	NETEVFWD, NETOPT
%

%	Copyright (c) Ian T Nabney (1996-2001)

fstr = [net.type, 'deriv'];
net = netunpak(net, w);
g = feval(fstr, net, x);
