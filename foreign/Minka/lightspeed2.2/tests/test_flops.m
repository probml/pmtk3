if 0
  % run under matlab 5
  a = rand(2,3);
  b = rand(3,4);
  c = rand(3);
  flops(0); a+a; flops
  flops(0); a.*a; flops
  flops(0); a./a; flops
  flops(0); a<a; flops
  flops(0); exp(a); flops
  flops(0); log(a); flops
  flops(0); a*a'; flops
  flops(0); a*b; flops
  flops(0); a/b'; flops
  
  ns = 1:10;
  f = [];
  for n = ns
    c = rand(n);
    c = c*c';
    flops(0); chol(c); f(n) = flops;
  end
  f = [1 5 14 30 55 91 140 204 285 385];
  x = [ones(size(ns)); ns; ns.^2; ns.^3];
  a = f/x
  plot(ns,f - a*x)
end

niter = 2000;
a = rand(100);
b = rand(100);
if 0
  tic; for i=1:niter ones(100); end; t_ones=toc/niter;
  fprintf('time for ones: %g\n', t_ones);
else
  t_ones = 0;
end
t = [];
tic; for i=1:niter a+4; end; t(1)=toc/niter;
tic; for i=1:niter a+b; end; t(2)=toc/niter;
tic; for i=1:niter a.*b; end; t(3)=toc/niter;
t_arith = mean(t) - t_ones;
fprintf('average for +,*: %g\n', t_arith);
if 0
  % By time, == takes 2 flops, but this is processor dependent.
  t = [];
  tic; for i=1:niter a>b; end; t=toc/niter;
  fprintf('time for >: %g\tflops = %g (should be %g)\n', t, t/t_arith, 2);
  %tic; for i=1:niter a==b; end; t=toc/niter;
  tic; for i=1:niter a~=b; end; t=toc/niter;
  fprintf('time for ~=: %g\tflops = %g\n', t, t/t_arith);
end
if 0
  tic; for i=1:niter randn(100); end; t=toc/niter;
  t = t-t_ones;
  fprintf('time for randn: %g\tflops = %g\n', t, t/t_arith);
end
if 0
  tic; for i=1:niter a.^(0.51); end; t=toc/niter;
  e1 = exp(1);
  tic; for i=1:niter e1.^a; end; t=toc/niter;
  t = t-t_ones;
  fprintf('time for pow: %g\tflops = %g\n', t, t/t_arith);
  if 0
    tic; for i=1:niter a.^(0.5); end; toc
    tic; for i=1:niter sqrt(a); end; toc
  end
end
tic; for i=1:niter sqrt(a); end; t_sqrt=toc/niter;
fprintf('time for sqrt: %g\tflops = %g (should be %g)\n', t_sqrt, t_sqrt/t_arith, flops_sqrt);
tic; for i=1:niter exp(a); end; t_exp=toc/niter;
fprintf('time for  exp: %g\tflops = %g (should be %g)\n', t_exp, t_exp/t_arith, flops_exp);
tic; for i=1:niter pow2(a); end; t_pow2=toc/niter;
fprintf('time for pow2: %g\tflops = %g (should be %g)\n', t_pow2, t_pow2/t_arith, flops_exp);
tic; for i=1:niter log(a); end; t_log=toc/niter;
fprintf('time for  log: %g\tflops = %g (should be %g)\n', t_log, t_log/t_arith, flops_log);
tic; for i=1:niter log2(a); end; t_log=toc/niter;
fprintf('time for log2: %g\tflops = %g (should be %g)\n', t_log, t_log/t_arith, flops_log);
