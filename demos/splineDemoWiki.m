% http://en.wikipedia.org/wiki/Multivariate_adaptive_regression_splines

figure; hold on;
xs = 0:0.1:20;
plot(xs, max(0,xs-13), '-', 'linewidth', 3);
plot(xs, max(0,13-xs), 'r:', 'linewidth', 3);
printPmtkFigure('splineDemoHinge')

figure;
xs = 0:0.1:20;
%f = @(x) 25+6.1*max(0,x-13) -3.1*max(0,13-x);
%f = @(x) 25  -4*max(0,x-5) + 6.1*max(0,x-13) -3.1*max(0,13-x);
f = @(x) 25  -4*max(0,x-5) + 6.1*max(0,x-13);
%f = @(x) 25  -4*max(0,(x-5).^2) + 6.1*max(0,(x-13));
plot(xs, f(xs), '-', 'linewidth', 3);
axis_pct
printPmtkFigure('splineDemo1d')

figure;
f = @(x,y) 5 + 1*max(0,x-5) -2*max(x-10) ...
  -3*max(0,5-y) -1.01*max(0,y-10).*max(0,x-8);
[x, y] = meshgrid(0:0.1:20, 0:0.1:20); 
z= reshape(f(x(:),y(:)), size(x));
surf(x,y,z);
set(gca,'zlim',[-50 0])

%{
figure;
f = @(x,y) 5.2 + 0.93*max(0,x-58) -0.64*max(x-68) ...
  -0.046*max(0,234-x) -0.016*max(0,y-7).*max(0,200-x);
[x, y] = meshgrid(0:1:300, 0:0.1:10); 
z= reshape(f(x(:),y(:)), size(x));
surf(x,y,z);
%}