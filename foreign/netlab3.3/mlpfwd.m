function [y, z, a] = mlpfwd(net, x)
%MLPFWD	Forward propagation through 2-layer network.
%
%	Description
%	Y = MLPFWD(NET, X) takes a network data structure NET together with a
%	matrix X of input vectors, and forward propagates the inputs through
%	the network to generate a matrix Y of output vectors. Each row of X
%	corresponds to one input vector and each row of Y corresponds to one
%	output vector.
%
%	[Y, Z] = MLPFWD(NET, X) also generates a matrix Z of the hidden unit
%	activations where each row corresponds to one pattern.
%
%	[Y, Z, A] = MLPFWD(NET, X) also returns a matrix A  giving the summed
%	inputs to each output unit, where each row corresponds to one
%	pattern.
%
%	See also
%	MLP, MLPPAK, MLPUNPAK, MLPERR, MLPBKP, MLPGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'mlp', x);
if ~isempty(errstring);
  error(errstring);
end

ndata = size(x, 1);

z = tanh(x*net.w1 + ones(ndata, 1)*net.b1);
a = z*net.w2 + ones(ndata, 1)*net.b2;

switch net.outfn

  case 'linear'    % Linear outputs

    y = a;

  case 'logistic'  % Logistic outputs
    % Prevent overflow and underflow: use same bounds as mlperr
    % Ensure that log(1-y) is computable: need exp(a) > eps
    maxcut = -log(eps);
    % Ensure that log(y) is computable
    mincut = -log(1/realmin - 1);
    a = min(a, maxcut);
    a = max(a, mincut);
    y = 1./(1 + exp(-a));

  case 'softmax'   % Softmax outputs
  
    % Prevent overflow and underflow: use same bounds as glmerr
    % Ensure that sum(exp(a), 2) does not overflow
    maxcut = log(realmax) - log(net.nout);
    % Ensure that exp(a) > 0
    mincut = log(realmin);
    a = min(a, maxcut);
    a = max(a, mincut);
    temp = exp(a);
    y = temp./(sum(temp, 2)*ones(1, net.nout));

  otherwise
    error(['Unknown activation function ', net.outfn]);  
end
