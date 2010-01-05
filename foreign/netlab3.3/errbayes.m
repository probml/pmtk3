function [e, edata, eprior] = errbayes(net, edata)
%ERRBAYES Evaluate Bayesian error function for network.
%
%	Description
%	E = ERRBAYES(NET, EDATA) takes a network data structure  NET together
%	the data contribution to the error for a set of inputs and targets.
%	It returns the regularised error using any zero mean Gaussian priors
%	on the weights defined in NET.
%
%	[E, EDATA, EPRIOR] = ERRBAYES(NET, X, T) additionally returns the
%	data and prior components of the error.
%
%	See also
%	GLMERR, MLPERR, RBFERR
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Evaluate the data contribution to the error.
if isfield(net, 'beta')
  e1 = net.beta*edata;
else
  e1 = edata;
end

% Evaluate the prior contribution to the error.
if isfield(net, 'alpha')
   w = netpak(net);
   if size(net.alpha) == [1 1]
      eprior = 0.5*(w*w');
      e2 = eprior*net.alpha;
   else
      if (isfield(net, 'mask'))
         nindx_cols = size(net.index, 2);
         nmask_rows = size(find(net.mask), 1);
         index = reshape(net.index(logical(repmat(net.mask, ...
            1, nindx_cols))), nmask_rows, nindx_cols);
      else
         index = net.index;
      end
      eprior = 0.5*(w.^2)*index;
      e2 = eprior*net.alpha;
   end
else
  eprior = 0;
  e2 = 0;
end

e = e1 + e2;
