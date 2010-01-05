% timing test for row_sum

% each trial should take the same amount of time
% if not, then you are not managing the cache properly
tim = [];
for k = 1:6
  x = randn(1024*k/4, 400);
  niter = floor(120/k);

  tic; for i = 1:niter sum(x,2); end; tim(k,1) = toc;
  tic; for i = 1:niter row_sum(x); end; tim(k,2) = toc;
  tic; for i = 1:niter x*ones(cols(x),1); end; tim(k,3) = toc;
  tic; for i = 1:niter sum(x')'; end; tim(k,4) = toc;
end
figure(1)
clf
plot(tim)
xlabel('trial')
ylabel('time (sec)')
legend('sum(x,2)', 'rowsum', 'product', 'sum(x'')''', 2)
tim(end,1)
