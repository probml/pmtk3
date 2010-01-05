function [e, edata, eprior, y, a] = glmerr(net, x, t)
%GLMERR	Evaluate error function for generalized linear model.
%
%	Description
%	 E = GLMERR(NET, X, T) takes a generalized linear model data
%	structure NET together with a matrix X of input vectors and a matrix
%	T of target vectors, and evaluates the error function E. The choice
%	of error function corresponds to the output unit activation function.
%	Each row of X corresponds to one input vector and each row of T
%	corresponds to one target vector.
%
%	[E, EDATA, EPRIOR, Y, A] = GLMERR(NET, X, T) also returns the data
%	and prior components of the total error.
%
%	[E, EDATA, EPRIOR, Y, A] = GLMERR(NET, X) also returns a matrix Y
%	giving the outputs of the models and a matrix A  giving the summed
%	inputs to each output unit, where each row corresponds to one
%	pattern.
%
%	See also
%	GLM, GLMPAK, GLMUNPAK, GLMFWD, GLMGRAD, GLMTRAIN
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'glm', x, t);
if ~isempty(errstring);
  error(errstring);
end

[y, a] = glmfwd(net, x);

switch net.outfn

  case 'linear'  	% Linear outputs
    edata = 0.5*sum(sum((y - t).^2));

  case 'logistic'  	% Logistic outputs
    edata = - sum(sum(t.*log(y) + (1 - t).*log(1 - y)));

  case 'softmax'   	% Softmax outputs
    edata = - sum(sum(t.*log(y)));

  otherwise
    error(['Unknown activation function ', net.outfn]);
end

[e, edata, eprior] = errbayes(net, edata);
