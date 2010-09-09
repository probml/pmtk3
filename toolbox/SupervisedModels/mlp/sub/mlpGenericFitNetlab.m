function [model, output] = mlpGenericFitNetlab(X, y, H, lambda, options, type)
% Train a multi-layer perceptron; needs netlab and minFunc
% X is an N*D matrix of inputs
% y should be a N*K matrix contain reals or 0,1
% type is 'linear', 'logistic' or 'softmax'
% H is the number of hidden nodes (single layer)
% lambda is the strength of the L2 regularizer on the weights (not biases)
% output is the return value from minFunc

% This file is from pmtk3.googlecode.com


if nargin < 6, options.Display = 'none';  end
[N,D] = size(X);
[N1,K] = size(y); %#ok
net = mlp(D, H, K, type, lambda);

w = netpak(net);
[w,f,exitflag,output] = minFunc(@funAndGrad,w(:),options); %#ok
net = mlpunpak(net, w);

if strcmpi(type, 'linear')
  yhat = mlpfwd(net, X);
  sigma2 = mean((y(:) - yhat(:)).^2);
  net.beta = 1/sigma2;
end
model.net = net;
model.type = type;

  function [e,g] = funAndGrad(w)
    net = mlpunpak(net, w);
    if strcmpi(type, 'linear')
      yhat = mlpfwd(net, X);
      sigma2 = mean((y(:) - yhat(:)).^2);
      net.beta = 1/sigma2;
      % must specify beta before calling mlperr (which calls errbayes)
      % mlperr also calls mlpfwd again, which is redundany
    end
    [e] = mlperr(net, X, y);
    [g] = mlpgrad(net, X, y);
    g = g(:);
  end

end


