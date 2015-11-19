%% Visualize projection onto the principal components
%
%%

% This file is from pmtk3.googlecode.com

setSeed(0);
n = 5;
X=[randn(n,2)+2.*ones(n,2);2.*randn(n,2)-2.*ones(n,2)];
[n d] = size(X);


%%%
[W, Z, evals, Xrecon2, mu] = pcaPmtk(X, 2);
Xrecon1 = Z(:,1)*W(:,1)' +  repmat(mu, n, 1);
figure;
plot(X(:,1), X(:,2), 'bo', 'markersize', 10); 
hold on
w=W(:,1);sf=6;h=line([-sf*w(1) sf*w(1)], [-sf*w(2) sf*w(2)]);
set(h,'color','k','linewidth',3);
w=W(:,2);sf=4;h=line([-sf*w(1) sf*w(1)], [-sf*w(2) sf*w(2)]);
set(h,'color','g','linewidth',3,'linestyle',':');
axis equal
printPmtkFigure('pcaDemo2dAxes');

%%%
[W, Z, evals, Xrecon, mu] = pcaPmtk(X, 1);
figure;
plot(mu(1), mu(2), '*', 'markersize', 15, 'color', 'r');
hold on
plot(X(:,1), X(:,2), 'bo', 'markersize', 10);
plot(Xrecon(:,1), Xrecon(:,2), 'r+', 'markersize', 10);
for i=1:n
  h=line([Xrecon(i,1) X(i,1)], [Xrecon(i,2) X(i,2)], 'color', 'r');
end
% plot the linear subspace
Z2 = [-5;5]; % 2 ``extreme'' points in latent space
Xrecon2 = Z2*W' + repmat(mu, 2,1);
h=line([Xrecon2(1,1) Xrecon2(2,1)], [Xrecon2(1,2) Xrecon2(2,2)], 'color', 'k');
axis equal
printPmtkFigure('pcaDemo2dProjection');

%ll = ppcaLogprob(X, W, mu, sigma2, evecs, evals)
