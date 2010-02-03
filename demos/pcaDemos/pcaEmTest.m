
%setSeed(1);
n = 100; d = 5;
X = randn(n,d);
k = 2;

tic;
[W, Xproj, evals, Xrecon, mu] = pcaFast(X,k);
toc

tic;
[W1, Xproj1, evals1, Xrecon1, mu1, iter] = pcaEm(X,k);
toc
iter

max(abs(W1(:))-abs(W(:)))
mse = mean((Xrecon(:) - X(:)).^2)
mse2 = mean((Xrecon1(:) - X(:)).^2)