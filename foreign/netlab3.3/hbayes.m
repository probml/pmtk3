function [h, hdata] = hbayes(net, hdata) 
%HBAYES	Evaluate Hessian of Bayesian error function for network.
%
%	Description
%	H = HBAYES(NET, HDATA) takes a network data structure NET together
%	the data contribution to the Hessian for a set of inputs and targets.
%	It returns the regularised Hessian using any zero mean Gaussian
%	priors on the weights defined in NET.  In addition, if a MASK is
%	defined in NET, then the entries in H that correspond to weights with
%	a 0 in the mask are removed.
%
%	[H, HDATA] = HBAYES(NET, HDATA) additionally returns the data
%	component of the Hessian.
%
%	See also
%	GBAYES, GLMHESS, MLPHESS, RBFHESS
%

%	Copyright (c) Ian T Nabney (1996-2001)

if (isfield(net, 'mask'))
  % Extract relevant entries in Hessian
  nmask_rows = size(find(net.mask), 1);
  hdata = reshape(hdata(logical(net.mask*(net.mask'))), ...
     nmask_rows, nmask_rows);
  nwts = nmask_rows;
else
  nwts = net.nwts;
end
if isfield(net, 'beta')
  h = net.beta*hdata;
else
  h = hdata;
end

if isfield(net, 'alpha')
  if size(net.alpha) == [1 1]
    h = h + net.alpha*eye(nwts);
  else
    if isfield(net, 'mask')
      nindx_cols = size(net.index, 2);
      index = reshape(net.index(logical(repmat(net.mask, ...
         1, nindx_cols))), nmask_rows, nindx_cols);
    else
      index = net.index;
    end
    h = h + diag(index*net.alpha);
  end 
end
