function decisionBoundariesDemo

% Decision boundaries induced by a mixture of two or three 2D Gaussians
% Based on code by Tommi Jaakkola

% 2 class
% linear decision boundary, with means on opposite sides
figure;
p1 = 0.5; p2 = 1-p1;
mu1 = [1 1]'; mu2 = [-1 -1]';
S1 = eye(2); S2 = eye(2);
plotgaussians2(p1, mu1, S1, p2, mu2, S2);
title('linear boundary')
printPmtkFigure('dboundaries2classLinear'); 


% parabolic decision boundary
figure;
p1 = 0.5; p2 = 1-p1;
mu1 = [1 1]'; mu2 = [-1 -1]';
S1 = [2 0; 0 1]; S2 = eye(2);
plotgaussians2(p1, mu1, S1, p2, mu2, S2);
title('parabolic boundary')
printPmtkFigure('dboundaries2classParabolic'); 


% 3 class
p1 = 1/3; p2 = 1/3; p3 = 1/3;
mu1 = [0 0]'; mu2 = [0 5]'; mu3 = [5 5]';

figure;
S1 = eye(2); S2 = eye(2); S3 = eye(2); 
plotgaussians3(p1, mu1, S1, p2, mu2, S2, p3, mu3, S3);
title('All boundaries are linear')
printPmtkFigure('dboundaries3classLinear'); 

figure;
S1 = [4 0; 0 1]; S2 = eye(2); S3 = eye(2); 
plotgaussians3(p1, mu1, S1, p2, mu2, S2, p3, mu3, S3);
title('Some linear, some quadratic')
printPmtkFigure('dboundaries3classParabolic');

%%%

function h = plotgaussians3(p1,mu1,S1,p2,mu2,S2,p3,mu3,S3)

[x,y] = meshgrid(linspace(-10,10,100), linspace(-10,10,100));
[m,n]=size(x);
X = [reshape(x, n*m, 1) reshape(y, n*m, 1)];
g1 = reshape(mvnpdf(X, mu1(:)', S1), [m n]);
g2 = reshape(mvnpdf(X, mu2(:)', S2), [m n]);
g3 = reshape(mvnpdf(X, mu3(:)', S3), [m n]);
hold on;
contour(x,y,g1, 'r:');
contour(x,y,g2, 'b--');
contour(x,y,g3, 'g-.');
% decision boundaries
[cc,hh]=contour(x,y,g1*p1-max(g2*p2, g3*p3),[0 0],'-k');  set(hh,'linewidth',3);
[cc,hh]=contour(x,y,g2*p2-max(g1*p1, g3*p3),[0 0],'-k');  set(hh,'linewidth',3);
[cc,hh]=contour(x,y,g3*p3-max(g2*p2, g1*p1),[0 0],'-k');  set(hh,'linewidth',3);

function h = plotgaussians2(p1,mu1,S1,p2,mu2,S2)

[x,y] = meshgrid(linspace(-10,10,100), linspace(-10,10,100));
[m,n]=size(x);
X = [reshape(x, n*m, 1) reshape(y, n*m, 1)];
g1 = reshape(mvnpdf(X, mu1(:)', S1), [m n]);
g2 = reshape(mvnpdf(X, mu2(:)', S2), [m n]);
hold;
contour(x,y,g1, 'r:');
contour(x,y,g2, 'b--');
[cc,hh]=contour(x,y,p1*g1-p2*g2,[0 0], '-k');
set(hh,'linewidth',3);
axis equal
