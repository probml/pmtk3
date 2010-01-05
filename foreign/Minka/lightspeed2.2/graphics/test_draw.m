n = 2;
% cov
c = randn(n);
c = c'*c;
c = [1 0.5; 0.5 1];

figure(1);clf
h = draw_circle(rand(2,n), rand(1,n), 'b', 'g');
h = draw_circle(rand(2,n), rand(1,n), 'c');
x = rand(2,n);
h = draw_ellipse(x, c, 'r');
h = draw_ellipse_axes(x, c, 'r:');
axis equal
