
setSeed(1);

N = 100; D = 2;
mu = randn(1,D);
Sigma = randpd(D);
X = gaussSample(mu, Sigma, N);


%[muHat1d, SigmaHat1d, dofHat1d, niter1d] = ...
%  studentFitEm(X, dof,  useECME, useSpeedup, verbose);

[muHat, SigmaHat, niter] = studentFitEm(X, 10, true)

[muHat2, SigmaHat2, niter2] = studentFitEm(X, [],  true)

