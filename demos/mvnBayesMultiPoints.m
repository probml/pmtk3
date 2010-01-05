
setSeed(0);
muTrue = [0.5 0.5]'; Ctrue = 0.1*[2 1; 1 1];
mtrue = MvnDist(muTrue, Ctrue);
xrange = [-1 1 -1 1];
n = 50;
X = sample(mtrue, n);
ns = [1 5 10 50];
figure;
nr = 2; nc = 3;
subplot(nr, nc,1);
plot(X(:,1), X(:,2), '.', 'markersize',15); axis(xrange);
hold on
plot(muTrue(1), muTrue(2), 'kx', 'markersize', 15, 'linewidth',3 );
axis square
title('data')

prior = MvnDist([0 0]', 0.1*eye(2));
subplot(nr, nc,2);
gaussPlot2d(prior.params.mu, prior.params.Sigma, '-plotMarker', true);
%plotPdf(prior);
axis(xrange);axis square
title('prior')

for i=1:length(ns)
  n = ns(i);
  py = MvnDist(zeros(2,1), Ctrue/n);
  A = eye(2); y = mean(X(1:n,:))';
  post = softCondition(prior, py, A, y);
  subplot(nr, nc,i+2);
  gaussPlot2d(post.params.mu, post.params.Sigma, '-plotMarker', true);
  %plotPdf(post);
  axis(xrange);
  axis square
  title(sprintf('n=%d',n))
end
printPmtkFigure('mvnBayesMultiPoints')

