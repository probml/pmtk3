%% Compare pcaPmtk and pcaFitEm
%
%%
%setSeed(1);

% This file is from pmtk3.googlecode.com

n = 100; d = 5;
X = randn(n,d);
k = 2;

tic;
[W, Xproj, evals, Xrecon, mu] = pcaPmtk(X,k);
toc

tic;
[W1, Xproj1, evals1, Xrecon1, mu1, iter] = pcaFitEm(X,k);
toc
iter

max(abs(W1(:))-abs(W(:)))
mse = mean((Xrecon(:) - X(:)).^2)
mse2 = mean((Xrecon1(:) - X(:)).^2)
