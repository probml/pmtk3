function [g, gdata, gprior] = gbayes(net, gdata)
%GBAYES	Evaluate gradient of Bayesian error function for network.
%
%	Description
%	G = GBAYES(NET, GDATA) takes a network data structure NET together
%	the data contribution to the error gradient for a set of inputs and
%	targets. It returns the regularised error gradient using any zero
%	mean Gaussian priors on the weights defined in NET.  In addition, if
%	a MASK is defined in NET, then the entries in G that correspond to
%	weights with a 0 in the mask are removed.
%
%	[G, GDATA, GPRIOR] = GBAYES(NET, GDATA) additionally returns the data
%	and prior components of the error.
%
%	See also
%	ERRBAYES, GLMGRAD, MLPGRAD, RBFGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Evaluate the data contribution to the gradient.
if (isfield(net, 'mask'))
   gdata = gdata(logical(net.mask));
end
if isfield(net, 'beta')
  g1 = gdata*net.beta;
else
  g1 = gdata;
end

% Evaluate the prior contribution to the gradient.
if isfield(net, 'alpha')
   w = netpak(net);
   if size(net.alpha) == [1 1]
      gprior = w;
      g2 = net.alpha*gprior;
   else
      if (isfield(net, 'mask'))
         nindx_cols = size(net.index, 2);
         nmask_rows = size(find(net.mask), 1);
         index = reshape(net.index(logical(repmat(net.mask, ...
            1, nindx_cols))), nmask_rows, nindx_cols);
      else
         index = net.index;
      end
      
      ngroups = size(net.alpha, 1);
      gprior = index'.*(ones(ngroups, 1)*w);
      g2 = net.alpha'*gprior;
   end
else
  gprior = 0;
  g2 = 0;
end

g = g1 + g2;
