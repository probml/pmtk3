%% Test that the minfunc method and IRLS give same result
%
%%

% This file is from pmtk3.googlecode.com

setSeed(0); 
N = 10; D = 2;
X = randn(N, D);
y01 = rand(N,1) > 0.5;
y12 = canonizeLabels(y01);
ypm = sign(y01-0.5);

lambda = 0;
opts.maxIter = 1000;
opts.TolX   = 1e-6;
opts.TolFun = 1e-6;
%opts.Display = 'none';
pp = preprocessorCreate('standardizeX', false, 'addOnes', true);
model1 = logregFit(X, y01, 'lambda', lambda, 'preproc', pp, 'fitOptions', opts);
model2 = logregBinaryFitL2IRLS(X, y01,lambda);
assert(approxeq(model1.w, model2.w))
