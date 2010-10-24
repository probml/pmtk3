
% This file is from pmtk3.googlecode.com

function [Xtest,xrange, yrange] = makeGrid2d(data, expand)

if nargin < 2, expand = 0.05; end

x0 = min(data(:,1));
x1 = max(data(:,1));
y0 = min(data(:,2));
y1 = max(data(:,2));
dx = x1-x0;
dy = y1-y0;
x0 = x0 - dx*expand;
x1 = x1 + dx*expand;
y0 = y0 - dy*expand;
y1 = y1 + dy*expand;
resolution = 100;
step = dx/resolution;
xrange = [x0:step:x1];
yrange = [y0:step:y1];
[X Y] = meshgrid(xrange, yrange);
Xtest = [X(:) Y(:)];
