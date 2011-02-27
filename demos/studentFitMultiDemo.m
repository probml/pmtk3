%% Fit multivariate student T distribution usign ECME
%
%%

% This file is from pmtk3.googlecode.com

setSeed(1);

N = 100; D = 2;
mu = randn(1,D);
Sigma = randpd(D);
model = struct('mu', mu, 'Sigma', Sigma);
X = gaussSample(model, N);


%[muHat1d, SigmaHat1d, dofHat1d, niter1d] = ...
%  studentFitEm(X, dof,  useECME, useSpeedup, verbose);

[model1, llhist1] = studentFitEm(X, 'dof', 10, 'useECME', true);
niter1 = length(llhist1)

[model2, llhist2] = studentFitEm(X, 'useECME',  true);
niter2 = length(llhist2)

