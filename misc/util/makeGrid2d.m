function [Xtest, xrange, yrange, X, Y] = makeGrid2d(data)
% make a 2d grid of points that spans the range of the training data
% data(:,1:2) are the x,y coords of training point i

x0 = min(data(:,1));
x1 = max(data(:,1));
y0 = min(data(:,2));
y1 = max(data(:,2));
dx = x1-x0;
dy = y1-y0;
expand = 5/100;			% Add on 5 percent each way
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
