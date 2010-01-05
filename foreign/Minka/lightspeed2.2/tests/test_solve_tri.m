[dummy,T] = lu(rand(5));
b = rand(5,1);
%fprintf('The columns should be equal:\n');
r = [solve_triu(T,b) T\b];
assert(all(abs(r(:,1) - r(:,2)) < 1e-10))
r = [solve_tril(T',b) T'\b];
assert(all(abs(r(:,1) - r(:,2)) < 1e-10))
fprintf('Verified that solve_triu and solve_tril results match backslash.\n');

d = 100;
niter = (20000/d)^2;
A = rand(d);
[dummy,T] = lu(A);
b = rand(d,1);
tic; for i = 1:niter T\b; end; t1=toc/niter;
tic; for i = 1:niter solve_triu(T,b); end; t2=toc/niter;
fprintf('backslash: \t%g\nsolve_triu: \t%g (%g times faster)\n',t1,t2,t1/t2);
% backslash is detecting triangularity as a preprocessing step, which doubles
% the time.
%fprintf('by flops, should be %g times faster\n',...
%    flops_solve(T,b)/flops_solve_tri(T,b));

niter = ceil(niter/d);
tic; for i = 1:niter inv(T); end; t1=toc/niter;
%I = eye(size(T));
%tic; for i = 1:niter solve_triu(T,I); end; t2=toc;
tic; for i = 1:niter inv_triu(T); end; t2=toc/niter;
fprintf('inv: \t%g\ninv_triu: \t%g (%g times faster)\n',t1,t2,t1/t2);
fprintf('by flops, should be %g times faster\n',...
    flops_inv(rows(T))/flops_solve_tri(T,eye(size(T))));
