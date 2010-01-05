function jac = rbfjacob(net, x)
%RBFJACOB Evaluate derivatives of RBF network outputs with respect to inputs.
%
%	Description
%	G = RBFJACOB(NET, X) takes a network data structure NET and a matrix
%	of input vectors X and returns a three-index matrix G whose I, J, K
%	element contains the derivative of network output K with respect to
%	input parameter J for input pattern I.
%
%	See also
%	RBF, RBFGRAD, RBFBKP
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'rbf', x);
if ~isempty(errstring);
  error(errstring);
end

if ~strcmp(net.outfn, 'linear')
  error('Function only implemented for linear outputs')
end

[y, z, n2] = rbffwd(net, x);

ndata = size(x, 1);
jac = zeros(ndata, net.nin, net.nout);
Psi = zeros(net.nin, net.nhidden);
% Calculate derivative of activations wrt n2
switch net.actfn
case 'gaussian'
  dz = -z./(ones(ndata, 1)*net.wi);
case 'tps'
  dz = 2*(1 + log(n2+(n2==0)));
case 'r4logr'
  dz = 2*(n2.*(1+2.*log(n2+(n2==0))));
otherwise
   error(['Unknown activation function ', net.actfn]);
end

% Ignore biases as they cannot affect Jacobian
for n = 1:ndata
  Psi = (ones(net.nin, 1)*dz(n, :)).* ...
    (x(n, :)'*ones(1, net.nhidden) - net.c');
  % Now compute the Jacobian
  jac(n, :, :) =  Psi * net.w2;
end