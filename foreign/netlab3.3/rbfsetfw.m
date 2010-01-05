function net = rbfsetfw(net, scale)
%RBFSETFW Set basis function widths of RBF.
%
%	Description
%	NET = RBFSETFW(NET, SCALE) sets the widths of the basis functions of
%	the RBF network NET. If Gaussian basis functions are used, then the
%	variances are set to the largest squared distance between centres if
%	SCALE is non-positive and SCALE times the mean distance of each
%	centre to its nearest neighbour if SCALE is positive.  Non-Gaussian
%	basis functions do not have a width.
%
%	See also
%	RBFTRAIN, RBFSETBF, GMMEM
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Set the variances to be the largest squared distance between centres
if strcmp(net.actfn, 'gaussian')
   cdist = dist2(net.c, net.c);
   if scale > 0.0
      % Set variance of basis to be scale times average
      % distance to nearest neighbour
      cdist = cdist + realmax*eye(net.nhidden);
      widths = scale*mean(min(cdist));
   else
      widths = max(max(cdist));
   end
   net.wi = widths * ones(size(net.wi));
end
