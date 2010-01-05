function g = glmderiv(net, x)
%GLMDERIV Evaluate derivatives of GLM outputs with respect to weights.
%
%	Description
%	G = GLMDERIV(NET, X) takes a network data structure NET and a matrix
%	of input vectors X and returns a three-index matrix mat{g} whose  I,
%	J, K element contains the derivative of network output K with respect
%	to weight or bias parameter J for input pattern I. The ordering of
%	the weight and bias parameters is defined by GLMUNPAK.
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'glm', x);
if ~isempty(errstring)
    error(errstring);
end

ndata = size(x, 1);
if isfield(net, 'mask')
  nwts = size(find(net.mask), 1);
  mask_array = logical(net.mask)*ones(1, net.nout);
else
  nwts = net.nwts;
end
g = zeros(ndata, nwts, net.nout);

temp = zeros(net.nwts, net.nout);
for n = 1:ndata
    % Weight matrix w1
    temp(1:(net.nin*net.nout), :) = kron(eye(net.nout), (x(n, :))');
    % Bias term b1
    temp(net.nin*net.nout+1:end, :) = eye(net.nout);
    if isfield(net, 'mask')
	g(n, :, :) = reshape(temp(find(mask_array)), nwts, net.nout);
    else
	g(n, :, :) = temp;
    end
end
