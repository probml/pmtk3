%% Error surface for linear regression model
% Based on code by John D'errico

% This file is from pmtk3.googlecode.com


function [X,y] = contoursSSEdemo(varargin)

if nargin == 0
    doPlot = true;
else
    doPlot = false;
end

setSeed(2);
n = 20;
if false
    %x = randn(n,1);
    x = linspace(-5, 5, n)';
else
    % if the data is not centered on 0, the regression problem becomes
    % harder (less well conditioned).
    x = linspace(1, 20, n)';
end
n = length(x);
wtrue = [1 1];
sigma = 1;
y = wtrue(1) + wtrue(2)*x + sigma*randn(n,1);


X = [ones(n,1),x];
w = X\y; % least squares soln

v = -1:.1:3;
%v = -5:.5:5;
nv = length(v);
[w0,w1] = meshgrid(v);
w0=w0(:)';
w1=w1(:)';
m = length(w0);

SS = sum(((ones(n,1)*w0 + x*w1) - repmat(y,1,m)).^2,1);
SS = reshape(SS,nv,nv);

if doPlot
figure;
surf(v,v,SS)
printPmtkFigure('linregSurfSSE')
end

if doPlot
figure
contour(v,v,SS)
hold on
plot(w(1),w(2),'rx', 'markersize', 14, 'linewidth', 3)
%plot(wtrue(1),wtrue(2),'bo', 'markersize', 14, 'linewidth', 3)
%plot([[-1;3],[1;1]],[[1;1],[-1;3]],'g-')
hold off
title 'Sum of squares error contours for linear regression'
axis equal
axis square
grid on
xlabel('w0')
ylabel('w1')
printPmtkFigure('linRegContoursSSE');
end

end

