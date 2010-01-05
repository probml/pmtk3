clear all; seed =  0; rand('state', seed);
n = 100; d = 5;
X = randn(n,d);
k = 2;

tic;
[W,mu,sigma2,evals,evecs,Xproj,Xrecon]  = ppcaFit(X,k);
toc

tic
[W2, ss2, mu2, Xproj2, Xcompleted] = ppca_mv(X,k,0);
toc
Xrecon2 = Xproj2*W2' + repmat(mu2, n, 1);


approxeq(W2, W)
approxeq(Xrecon2, Xrecon)
mse = mean((Xrecon(:) - X(:)).^2)
mse2 = mean((Xrecon2(:) - X(:)).^2)