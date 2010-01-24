% Test that the minfunc method and IRLS give same result

setSeed(0); 
N = 10; D = 2;
X = randn(N, D);
y01 = rand(N,1) > 0.5;
y12 = canonizeLabels(y01);
ypm = sign(y01-0.5);

lambda = 0;

model1 = logregL2Fit(X, y01, lambda);
model2 = logregL2FitNewton(X, y01,  lambda);
assert(approxeq(model1.w, model2.w))
