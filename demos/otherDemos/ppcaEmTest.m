%% Test ppcaFit by comparing to Verbeek's code with no missing data
% Fails!

% This file is from pmtk3.googlecode.com

setSeed(0);
n = 100; d = 5;
X = randn(n,d);
k = 2;

model = ppcaFit(X, k);
Xrecon = ppcaReconstruct(model, X);

[W2, ss2, mu2, Xproj2, Xcompleted] = ppca_mv(X,k,0);
Xrecon2 = Xproj2*W2' + repmat(mu2, n, 1);

approxeq(W2, model.W)
approxeq(Xrecon2, Xrecon)
mse = mean((Xrecon(:) - X(:)).^2)
mse2 = mean((Xrecon2(:) - X(:)).^2)
