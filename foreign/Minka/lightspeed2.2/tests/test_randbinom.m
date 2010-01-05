% Computes the speed difference between Matlab's binornd and 
% Lightspeed's randbinom.

p = 0.13;
n = 123;
tim = [];

nsamples = 1e4;
y = zeros(nsamples,1);
tic
for i = 1:nsamples
  y(i) = randbinom(p,n);
end
tim(1) = toc;
%g = int_hist(y+1,n+1)/nsamples;
tic
for i = 1:nsamples
  y(i) = binornd(n,p);
end
tim(2) = toc;
fprintf('Time for binornd: %g\n', tim(2));
fprintf('Time for randbinom: %g (%g times faster)\n', tim(1), tim(2)/tim(1));

if 0
  % test validity of the sampler (use nsamples = 1e5)
  x = 0:n;
  f = binopdf(x,n,p);
  plot(x,f,x,g)
  legend('true','estimated')
end
