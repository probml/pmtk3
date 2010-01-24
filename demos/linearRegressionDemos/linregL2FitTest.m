% check that different fitting methods for ridge regression give same result

n = 10;
X = rand(n,2);
%X = [ones(n,1) X];
y = randn(n,1);
lambda = 1e-2;
model1 = linregL2Fit(X, y, lambda);
model2 = linregL2FitMinfunc(X, y, lambda);
assert(approxeq(model1.w, model2.w))