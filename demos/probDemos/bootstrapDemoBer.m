%% bootstrap demo for MLE for Bernoulli
%PMTKslow
theta = 0.7;
Ns = [10 100];
for Ni=1:length(Ns)
N = Ns(Ni);
B = 10000;
setSeed(0);
X = rand(1,N) < theta;
estimator = @(X) mean(X);
mle = estimator(X);
mleBoot = zeros(1,B);
for b=1:B
  Xb = rand(1,N) < mle;
  mleBoot(b) = estimator(Xb);
  ndx = unidrnd(N,1,N);
  Xnonparam = X(ndx);
  mleBootNP(b) = estimator(Xnonparam);
end
figure;
hist(mleBoot)
set(gca,'xlim',[0 1])
ttl = sprintf('Boot: true = %3.2f, n=%d, mle = %3.2f, se = %5.3f\n', ...
  theta, N, mle, std(mleBoot)/sqrt(B));
title(ttl)
printPmtkFigure(sprintf('bootstrapDemoBer%d', N));

%{
figure;
hist(mleBootNP)
set(gca,'xlim',[0 1])
ttl = sprintf('NP boot: true = %3.2f, n=%d, mle = %3.2f, se = %5.3f\n', ...
  theta, N, mle, std(mleBootNP)/sqrt(B));
title(ttl)
printPmtkFigure(sprintf('bootstrapDemoBerNP%d', N));
%}

% Now do the Bayesian thing with an uniformative Beta prior
N1 = length(find(X==1));
N0 = length(find(X==0));
alpha1 = 1; alpha0 = 1;
Xpost = betarnd(N1+alpha1, N0+alpha0,1,B);
figure;
hist(Xpost);
set(gca,'xlim',[0 1])
ttl = sprintf('Bayes: true = %3.2f, n=%d, post mean = %3.2f, se = %5.3f\n', ...
  theta, N, mean(Xpost), std(Xpost)/sqrt(B));
title(ttl)
printPmtkFigure(sprintf('bootstrapDemoBerBayes%d', N));

end
