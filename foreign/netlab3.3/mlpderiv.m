function g = mlpderiv(net, x)
%MLPDERIV Evaluate derivatives of network outputs with respect to weights.
%
%	Description
%	G = MLPDERIV(NET, X) takes a network data structure NET and a matrix
%	of input vectors X and returns a three-index matrix G whose I, J, K
%	element contains the derivative of network output K with respect to
%	weight or bias parameter J for input pattern I. The ordering of the
%	weight and bias parameters is defined by MLPUNPAK.
%
%	See also
%	MLP, MLPPAK, MLPGRAD, MLPBKP
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'mlp', x);
if ~isempty(errstring);
  error(errstring);
end

[y, z] = mlpfwd(net, x);

ndata = size(x, 1);

if isfield(net, 'mask')
  nwts = size(find(net.mask), 1);
  temp = zeros(1, net.nwts);
else
  nwts = net.nwts;
end

g = zeros(ndata, nwts, net.nout);
for k = 1 : net.nout
  delta = zeros(1, net.nout);
  delta(1, k) = 1;
  for n = 1 : ndata
    if isfield(net, 'mask')
      temp = mlpbkp(net, x(n, :), z(n, :), delta);
      g(n, :, k) = temp(logical(net.mask));
    else
      g(n, :, k) = mlpbkp(net, x(n, :), z(n, :),...
	delta);
    end
  end
end
