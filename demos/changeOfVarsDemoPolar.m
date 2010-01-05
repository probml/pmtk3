% change of variables demo

xydist = MvnDist([0 0], eye(2));
%{
xr = -1:0.1:1;
nr = length(xr); nc = nr;
xy = crossProduct(xs, xs); % xy(i,:) = [x1(i) x2(i)] for grid point i
pxy = exp(logprob(xydist, xy));
%}
xrange = [-1 1 -1 1]; npoints = 20;
[X1,X2] = meshgrid(linspace(xrange(1), xrange(2), npoints)',...
  linspace(xrange(3), xrange(4), npoints)');
[nr] = size(X1,1); nc = size(X2,1);
X = [X1(:) X2(:)];
pxy = exp(logPdf(xydist, X));

r = sqrt(X(:,1).^2 + X(:,2).^2);
t = atan(X(:,2) ./ X(:,1));
prt = pxy .* r;

samples = sample(xydist, 1000);
rs = sqrt(samples(:,1).^2 + samples(:,2).^2);
ts = atan(samples(:,2) ./ samples(:,1));


figure(1);clf
subplot(2,2,1);contour(X1, X2, reshape(pxy, nr, nc)); title('cartesian')
subplot(2,2,2);contour(X1, X2, reshape(prt, nr, nc)); title('polar')
subplot(2,2,3);plot(samples(:,1), samples(:,2), '.'); title('cartesian');
subplot(2,2,4);plot(rs,ts,'.'); title('polar')


