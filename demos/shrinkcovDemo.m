% Demo of Ledoit-Wolf shrinkage for covariance matrix

setSeed(0);
d = 50;
%Sigma = randpd(d);
condnumber = 10; a = randn(d,1);
[Sigma] = covcond(condnumber,a);
cond(Sigma)
evalsTrue = sort(eig(Sigma),'descend');
mu = zeros(1,d);
f = [2 1 1/2]; % fraction of d
condNumMLE = zeros(1,3); condNumShrink = zeros(1,3);
for i=1:length(f)
  n = f(i)*d;
  X = mvnrnd(mu,Sigma,n);
  Smle = cov(X);
  evalsMle = sort(eig(Smle),'descend');
  Sshrink = shrinkcov(X);
  evalsShrink = sort(eig(Sshrink),'descend');
  figure(i);clf; hold on
  %ndx = 2:2:min(30,d);
  ndx = 1:d;
  if 1
    plot(evalsTrue(ndx), 'k-o', 'linewidth', 2, 'markersize', 10);
    plot(evalsMle(ndx), 'b-x', 'linewidth', 2, 'markersize', 10);
    plot(evalsShrink(ndx), 'r:s', 'linewidth', 2, 'markersize', 10);
    ylabel('eigenvalue')
    fname = sprintf('covshrinkDemoN%d', n);
  else
    plot(log(evalsTrue(ndx)), 'k-o', 'linewidth', 2, 'markersize', 12);
    z=log(evalsMle(ndx));
    for ii=1:length(z), if ~isreal(z(ii)), z(ii)=nan; end; end
    plot(z, 'b-x', 'linewidth', 2, 'markersize', 12);
    plot(log(evalsShrink(ndx)), 'r:s', 'linewidth', 2, 'markersize', 12);
    ylabel('log(eigenvalue)')
    fname = sprintf('covshrinkDemoLogN%d', n);
  end
  legend('true', 'mle', 'shrinkage')
  %title(sprintf('n=%d, d=%d',	n, d))
  %title(sprintf('n=%d, d=%d, cond(MLE)=%4.2f, cond(shrink)=%4.2f', ...
  %   n, d, cond(Smle), cond(Sshrink)))
  condNumMLE(i)  =  cond(Smle);
  condNumShrink(i) = cond(Sshrink);
  pdMLE(i) = isposdef(Smle);
  pdShrink(i) = isposdef(Sshrink);
  printPmtkFigure(fname); 
end
  
disp(condNumMLE)
disp(condNumShrink)


