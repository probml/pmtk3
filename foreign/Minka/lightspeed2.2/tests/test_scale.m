d = 500;
A = randn(d);
b = randn(d,1);
niter = 100;
fprintf('cols:')
tic; for i = 1:niter scale_cols(A,b); end; toc
fprintf('rows:')
tic; for i = 1:niter scale_rows(A,b); end; toc
