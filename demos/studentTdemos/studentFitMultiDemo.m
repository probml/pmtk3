
setSeed(1);

N = 100; D = 2;
mu = randn(1,D);
Sigma = randpd(D);
X = gaussSample(mu, Sigma, N);

[muHat, SigmaHat, niter] = studentFitEmFixedDof(X, 10, false)

[muHat2, SigmaHat2, niter2] = studentFitEmFixedDof(X, 10, true)

[muHat3, SigmaHat3, dof3, niter3] = studentFitEm(X, false)

[muHat4, SigmaHat4, dof4, niter4] = studentFitEm(X, true)

[muHat5, SigmaHat5, dof5, niter5] = studentFitEcme(X, false)

[muHat6, SigmaHat6, dof6, niter6] = studentFitEcme(X, true)

