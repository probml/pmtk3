x = [1 2; 3 4];
A = x*x';
sqdist(x,x)
sqdist(x,x,A)

niter = 2;
x = randn(300);
A = x*x';
fprintf('Euclidean:')
tic; for iter = 1:niter sqdist(x,x); end; toc
fprintf('Mahalanobis:')
tic; for iter = 1:niter sqdist(x,x,A); end; toc
