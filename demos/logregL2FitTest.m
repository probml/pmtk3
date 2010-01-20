% Test that the minfunc method and IRLS give same result

setSeed(0); 
N = 10; D = 2;
X = randn(N, D);
y01 = rand(N,1) > 0.5;
y12 = canonizeLabels(y01);
ypm = sign(y01-0.5);

lambda = 0;

[beta1] = logregL2Fit(X, y01, lambda);
[beta2, C] = logregL2FitNewton(X, y01,  lambda);
assert(approxeq(beta1, beta2))

[beta1] = logregL2Fit(X, y12, lambda);
[beta2, C] = logregL2FitNewton(X, y12,  lambda);
assert(approxeq(beta1, beta2))

[beta1] = logregL2Fit(X, ypm, lambda);
[beta2, C] = logregL2FitNewton(X, ypm,  lambda);
assert(approxeq(beta1, beta2))
