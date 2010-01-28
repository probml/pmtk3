
setSeed(1);
%{
N = 100; D = 2;
mu = randn(1,D);
Sigma = randpd(D);
X = gaussSample(mu, Sigma, N);

[muHat, SigmaHat, niter] = mvtFixedDofFitEm(X, 10, false);

[muHat2, SigmaHat2, niter2] = mvtFixedDofFitEm(X, 10, true);

[muHat3, SigmaHat3, dof3, niter3] = mvtFitEm(X, true)

[muHat4, SigmaHat4, dof4, niter4] = mvtFitEm(X, false)

[muHat5, SigmaHat5, dof5, niter5] = mvtFitEcme(X, false)
%}


% Now try 1d example - same data as gaussVsStudentOutlierDemo
n = 30;
seed = 8; randn('state',seed);
data = randn(n,1);
outliers = [8 ; 8.75 ; 9.5];
X = [data; outliers];
MLEs = mle(X,'distribution','tlocationscale')
mu1d = MLEs(1); sigma1d = MLEs(2); dof1d = MLEs(3);
[muHat1d, SigmaHat1d, dofHat1d, niter1d] = mvtFitEm(X, false, true);
fprintf('dof: matlab %3.2f, em %3.2f\n', dof1d, dofHat1d);
fprintf('mu: matlab %3.2f, em %3.2f\n', mu1d, muHat1d);
fprintf('sigma: matlab %3.2f, em %3.2f\n', sigma1d, sqrt(SigmaHat1d));
