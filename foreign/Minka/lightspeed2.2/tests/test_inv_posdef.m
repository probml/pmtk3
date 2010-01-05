N = 100;
niter = 100;
A = rand(N);
A = A*A';
tic; for i = 1:niter inv(A); end; t1=toc;
tic; for i = 1:niter inv_posdef(A); end; t2=toc;
fprintf('inv: \t%g\ninv_posdef: \t%g (%g times faster)\n',t1,t2,t1/t2);
