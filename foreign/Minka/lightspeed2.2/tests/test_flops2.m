% test flops for matrix operations

niter = 50000;
a = rand(100);
a = a*a';
T = chol(a);
b = rand(100);
c = rand(rows(a),1);

t = [];
tic; for i=1:niter a+4; end; t(1)=toc/niter;
tic; for i=1:niter a+b; end; t(2)=toc/niter;
tic; for i=1:niter a.*b; end; t(3)=toc/niter;
t_arith = mean(t);
%fprintf('average for +,*: %g\n', t_arith);
t_flop = t_arith/prod(size(a));
fprintf('time for 1 flop: %g\n', t_flop);

tic; for i=1:niter solve_triu(T,c); end; t_solve_triu=toc/niter;
fprintf('time for solve_triu: %g\tflops = %g (should be %d)\n', t_solve_triu, t_solve_triu/t_flop, flops_solve_tri(a,c));

niter = niter/10;
tic; for i=1:niter chol(a); end; t_chol=toc/niter;
fprintf('time for chol: %g\tflops = %g (should be %d)\n', t_chol, t_chol/t_flop, flops_chol(rows(a)));

tic; for i=1:niter det(a); end; t_det=toc/niter;
fprintf('time for det: %g\tflops = %g (should be %d)\n', t_det, t_det/t_flop, flops_det(rows(a)));

tic; for i=1:niter a\c; end; t_solve=toc/niter;
fprintf('time for solve: %g\tflops = %g (should be %d)\n', t_solve, t_solve/t_flop, flops_solve(a,c));

% matrix multiply is incredibly fast
tic; for i=1:niter a*b; end; t_mtimes=toc/niter;
fprintf('time for mtimes: %g\tflops = %g (should be %d)\n', t_mtimes, t_mtimes/t_flop, flops_mul(a,b));

niter = niter/10;
tic; for i=1:niter inv(a); end; t_inv=toc/niter;
fprintf('time for inv: %g\tflops = %g (should be %d)\n', t_inv, t_inv/t_flop, flops_inv(rows(a)));
