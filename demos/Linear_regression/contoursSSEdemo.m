% Error surface for linear regression model
% Based on code by John D'errico
setSeed(2);
n = 20;
x = randn(n,1);
%x = (-3:0.5:3)';
%n = length(x);
wtrue = [1 1];
sigma = 1;
y = wtrue(1) + wtrue(2)*x + sigma*randn(n,1);

%{
figure
plot(x,y,'o')
title 'Linear data with noise'
xlabel 'x'
ylabel 'y'
axis([-4 4 -3 5])
%}

X = [ones(n,1),x];
w = X\y % least squares soln

v = -1:.1:3;
%v = -5:.5:5;
nv = length(v);
[w0,w1] = meshgrid(v);
w0=w0(:)';
w1=w1(:)';
m = length(w0);

SS = sum(((ones(n,1)*w0 + x*w1) - repmat(y,1,m)).^2,1);
SS = reshape(SS,nv,nv);

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

figure;
surf(v,v,SS)
printPmtkFigure('linregSurfSSE')

