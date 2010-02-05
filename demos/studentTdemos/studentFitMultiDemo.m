
setSeed(1);

N = 100; D = 2;
mu = randn(1,D);
Sigma = randpd(D);
model = struct('mu', mu, 'Sigma', Sigma);
X = gaussSample(model, N);


%[muHat1d, SigmaHat1d, dofHat1d, niter1d] = ...
%  studentFitEm(X, dof,  useECME, useSpeedup, verbose);

[model1, niter] = studentFitEm(X, 10, true)

[model2, niter2] = studentFitEm(X, [],  true)

