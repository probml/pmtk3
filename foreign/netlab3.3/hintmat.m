function [xvals, yvals, color] = hintmat(w);
%HINTMAT Evaluates the coordinates of the patches for a Hinton diagram.
%
%	Description
%	[xvals, yvals, color] = hintmat(w)
%	  takes a matrix W and returns coordinates XVALS, YVALS for the
%	patches comrising the Hinton diagram, together with a vector COLOR
%	labelling the color (black or white) of the corresponding elements
%	according to their sign.
%
%	See also
%	HINTON
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Set scale to be up to 0.9 of maximum absolute weight value, where scale
% defined so that area of box proportional to weight value.

w = flipud(w);
[nrows, ncols] = size(w);

scale = 0.45*sqrt(abs(w)/max(max(abs(w))));
scale = scale(:);
color = 0.5*(sign(w(:)) + 3);

delx = 1;
dely = 1;
[X, Y] = meshgrid(0.5*delx:delx:(ncols-0.5*delx), 0.5*dely:dely:(nrows-0.5*dely));

% Now convert from matrix format to column vector format, and then duplicate
% columns with appropriate offsets determined by normalized weight magnitudes. 

xtemp = X(:);
ytemp = Y(:);

xvals = [xtemp-delx*scale, xtemp+delx*scale, ...
         xtemp+delx*scale, xtemp-delx*scale];
yvals = [ytemp-dely*scale, ytemp-dely*scale, ...
         ytemp+dely*scale, ytemp+dely*scale];

