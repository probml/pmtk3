%% Probabilistic PCA in 2D
% Based on figure 7.6 of the netlab book
%%

% This file is from pmtk3.googlecode.com

setSeed(0);
n = 5;
X=[randn(n,2)+2.*ones(n,2);2.*randn(n,2)-2.*ones(n,2)];
X = centerCols(X);
[n d] = size(X);
model = ppcaFit(X, 1);
%sigma2=eps;
Xrecon = ppcaReconstruct(model, X);
mu = model.mu;
figure;
plot(mu(1), mu(2), '*', 'markersize', 20, 'color', 'r');
hold on
plot(X(:,1), X(:,2), 'ro', 'markersize', 20);
hold on
plot(Xrecon(:,1), Xrecon(:,2), 'g+', 'markersize', 20, 'linewidth',2);
for i=1:n
  line([Xrecon(i,1) X(i,1)], [Xrecon(i,2) X(i,2)])
end
% plot the linear subspace
Z2 = [-2;1.5];
%Z2 = [-5;5]; % 2 ``extreme'' points in latent space
Xrecon2 = Z2*model.W' + repmat(rowvec(mu), 2,1);
line([Xrecon2(1,1) Xrecon2(2,1)], [Xrecon2(1,2) Xrecon2(2,2)], 'color', 'm')
axis;

printPmtkFigure('ppcaDemo2d'); 


