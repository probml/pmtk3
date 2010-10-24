function [h, p, c] = plotContour(fn, xyRange, varargin)
% Plot contours of the function
% evalatuated at xyRange = [xmin xmax ymin ymax].
%
% All other args (varargin) are passed directly to the contour function,
% except for 'npoints', which is by default 100 and 'ncontours'.
%%

% This file is from pmtk3.googlecode.com

[npoints, ncontours, args] = process_options(varargin, 'npoints', 100, 'ncontours', []);
if nargin < 2
    xyRange = [-10 10 -10 10];
end
npoints = 100;
[X1, X2] = meshgrid( linspace(xyRange(1), xyRange(2), npoints)', ...
    linspace(xyRange(3), xyRange(4), npoints)'  );
nr = size(X1, 1);  nc = size(X2, 1);
p = reshape(fn([X1(:) X2(:)]), nr, nc);
if isempty(ncontours)
    [c, h] = contour(X1, X2, p, args{:});
else
    [c, h] = contour(X1, X2, p, ncontours, args{:});
end
end
