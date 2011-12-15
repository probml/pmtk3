function [h, p] = plotSurface(fn, xyRange, varargin)
% Plot the surface of the function
% evalatuated at xyRange = [xmin xmax ymin ymax].
%
% All other args (varargin) are passed directly to the surf function,
% except for 'npoints', which is by default 100.
%%

% This file is from pmtk3.googlecode.com

[npoints, args] = process_options(varargin, 'npoints', 100);
if nargin < 2
    xyRange = [-10 10 -10 10];
end
[X1, X2] = meshgrid( linspace(xyRange(1), xyRange(2), npoints)', ...
    linspace(xyRange(3), xyRange(4), npoints)'  );
nr = size(X1, 1);  nc = size(X2, 1);
p = reshape(fn([X1(:) X2(:)]), nr, nc);
p(~isfinite(p)) = NaN;
%h = surf(X1, X2, p, args{:});
h = surfl(X1, X2, p, args{:});
%colormap(gray)
colormap(bone)
shading interp
%camproj perspective
end
