% ppcaDemo2d
% Based on figure 7.6 of the netlab book


seed = 0; randn('state', seed);
n = 5;
X=[randn(n,2)+2.*ones(n,2);2.*randn(n,2)-2.*ones(n,2)];
X = centerCols(X);
[n d] = size(X);
[W, mu, sigma2, evals, evecs] = ppcaFit(X, 1);
%sigma2=eps;
[Z, postCov] = ppcaPost(X, W, mu, sigma2, evals, evecs);
Xrecon = Z*W' + repmat(mu, n,1);
figure(2);clf;
plot(mu(1), mu(2), '*', 'markersize', 15, 'color', 'r');
hold on
plot(X(:,1), X(:,2), 'ro');
hold on
plot(Xrecon(:,1), Xrecon(:,2), 'g+', 'markersize', 12, 'linewidth',2);
for i=1:n
  line([Xrecon(i,1) X(i,1)], [Xrecon(i,2) X(i,2)])
end
% plot the linear subspace
Z2 = [-2;1.5];
%Z2 = [-5;5]; % 2 ``extreme'' points in latent space
Xrecon2 = Z2*W' + repmat(mu, 2,1);
line([Xrecon2(1,1) Xrecon2(2,1)], [Xrecon2(1,2) Xrecon2(2,2)], 'color', 'm')
axis;

printPmtkFigure('ppcaDemo2d'); 


