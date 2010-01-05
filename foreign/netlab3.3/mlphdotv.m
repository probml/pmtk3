function hdv = mlphdotv(net, x, t, v)
%MLPHDOTV Evaluate the product of the data Hessian with a vector. 
%
%	Description
%
%	HDV = MLPHDOTV(NET, X, T, V) takes an MLP network data structure NET,
%	together with the matrix X of input vectors, the matrix T of target
%	vectors and an arbitrary row vector V whose length equals the number
%	of parameters in the network, and returns the product of the data-
%	dependent contribution to the Hessian matrix with V. The
%	implementation is based on the R-propagation algorithm of
%	Pearlmutter.
%
%	See also
%	MLP, MLPHESS, HESSCHEK
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'mlp', x, t);
if ~isempty(errstring);
  error(errstring);
end

ndata = size(x, 1);

[y, z] = mlpfwd(net, x);		% Standard forward propagation.
zprime = (1 - z.*z);			% Hidden unit first derivatives.
zpprime = -2.0*z.*zprime;		% Hidden unit second derivatives.

vnet = mlpunpak(net, v);	% 		Unpack the v vector.

% Do the R-forward propagation.

ra1 = x*vnet.w1 + ones(ndata, 1)*vnet.b1;
rz = zprime.*ra1;
ra2 = rz*net.w2 + z*vnet.w2 + ones(ndata, 1)*vnet.b2;

switch net.outfn

  case 'linear'      % Linear outputs

    ry = ra2;

  case 'logistic'    % Logistic outputs

    ry = y.*(1 - y).*ra2;

  case 'softmax'     % Softmax outputs
  
    nout = size(t, 2);
    ry = y.*ra2 - y.*(sum(y.*ra2, 2)*ones(1, nout));

  otherwise
    error(['Unknown activation function ', net.outfn]);  
end

% Evaluate delta for the output units.

delout = y - t;

% Do the standard backpropagation.

delhid = zprime.*(delout*net.w2');

% Now do the R-backpropagation.

rdelhid = zpprime.*ra1.*(delout*net.w2') + zprime.*(delout*vnet.w2') + ...
          zprime.*(ry*net.w2');

% Finally, evaluate the components of hdv and then merge into long vector.

hw1 = x'*rdelhid;
hb1 = sum(rdelhid, 1);
hw2 = z'*ry + rz'*delout;
hb2 = sum(ry, 1);

hdv = [hw1(:)', hb1, hw2(:)', hb2];
