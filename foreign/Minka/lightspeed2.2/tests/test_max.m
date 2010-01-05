tim = [];
for k = 1:6
  x = rand(1,1024*k/2);
  %x = 1:(1024*k/4);
  niter = floor(12000/k);

  %tic; for i = 1:niter ismembc(b,a); end; tim(k,1) = toc;
  tic; for i = 1:niter max(x); end; tim(k,1) = toc;
  tic; for i = 1:niter min(x); end; tim(k,2) = toc;
  tic; for i = 1:niter all(x); end; tim(k,3) = toc;
  tic; for i = 1:niter any(x); end; tim(k,4) = toc;
  tic; for i = 1:niter x+x; end; tim(k,5) = toc;
end
figure(1),clf
plot(tim)
xlabel('trial')
ylabel('time (sec)')
legend('max','min','all','any','plus');
%tim(end,1)
