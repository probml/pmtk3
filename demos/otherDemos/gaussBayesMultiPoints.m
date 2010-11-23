%% Bayesian Sequential Updating of a Gaussian
%
%%

% This file is from pmtk3.googlecode.com

setSeed(0);
muTrue = [0.5 0.5]'; Ctrue = 0.1*[2 1; 1 1];
xrange = [-1 1 -1 1];
n = 50;
model = struct('mu', muTrue, 'Sigma', Ctrue);
X = gaussSample(model, n);
ns = [1 5 10 50];
figure;
nr = 2; nc = 3;
subplot(nr, nc,1);
plot(X(:,1), X(:,2), '.', 'markersize',15); axis(xrange);
hold on
plot(muTrue(1), muTrue(2), 'kx', 'markersize', 15, 'linewidth',3 );
axis square
title('data')

prior.mu = [0 0]';
prior.Sigma = 0.1*eye(2);

subplot(nr, nc,2);
gaussPlot2d(prior.mu, prior.Sigma, 'plotMarker', true);

axis(xrange);axis square
title('prior')

for i=1:length(ns)
  n = ns(i);
  py.mu = zeros(2, 1);
  py.Sigma = Ctrue/n;
  A = eye(2); y = mean(X(1:n,:))';
  post = gaussSoftCondition(prior, py, A, y);
  subplot(nr, nc,i+2);
  gaussPlot2d(post.mu, post.Sigma, 'plotMarker', true);
  axis(xrange);
  axis square
  title(sprintf('n=%d',n))
end
printPmtkFigure('mvnBayesMultiPoints')

