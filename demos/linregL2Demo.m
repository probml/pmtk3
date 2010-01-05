

n = 10;
X = rand(n,2);
%X = [ones(n,1) X];
y = randn(n,1);
lambda = 1e-2;
w = linregL2Fit(X, y, lambda);
w2 = linregL2FitMinfunc(X, y, lambda);
approxeq(w, w2)