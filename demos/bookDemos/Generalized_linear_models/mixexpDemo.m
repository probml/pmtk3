%% demo of mixture of linear regression experts in 1d

% This file is from pmtk3.googlecode.com


clear all
close all
setSeed(0);
%data = load('mixexp_data.txt');  % data from Mike Jordan's homework 
datasource = 3;
switch datasource
  case 1,
    xtrain = linspace(-1,1,200);
    Ntrain = numel(xtrain);
    ndx = (xtrain < 0)+1;
    w = [-1 1];
    ytrain = xtrain.*w(ndx) + 0.5*randn(1,Ntrain);
    data = [xtrain(:) ytrain(:)];
    K = 2;
  case 2,
    % reproduce bishop fig 14.8
    xtrain = linspace(-1,1,50);
    Ntrain = numel(xtrain);
    ndx(xtrain < -0.5) = 1;
    ndx( (xtrain > -0.5) & (xtrain < 0.5) ) = 2;
    ndx(xtrain > 0.5) = 3;
    w = 0.01*randn(1,3);
    b = [-1 1 -1];
    ytrain = xtrain.*w(ndx) + b(ndx) + 0.2*randn(1,Ntrain);
    data = [xtrain(:) ytrain(:)];
    K = 3;
  case 3,
    n = 200;
    t = rand(n,1);
    % eta = normrnd(0,0.05,n,1);
    eta = randn(n,1)*0.05;
    x = t + 0.3.*sin(2.*pi().*t) + eta;
    data = [x(:) t(:)];
    e = 3;
end




N = size(data,1);
ndx = 1:1:N;
X = data(ndx,1);
y = data(ndx,2);
xtest = colvec(linspace(min(X), max(X), 100));

figure;
plot(X, y, 'o', 'markersize', 10); hold on
printPmtkFigure(sprintf('mixexpData'))

for fixmix=[0 1]
  switch fixmix
    case 0, K=3;
    case 1, K=2;
  end
model = mixexpFit(X, y, K, 'fixmix', fixmix, 'EMargs', ...
  {'verbose', true, 'nrandomrestarts', 2});
[mu, v, post, muk, vk] = mixexpPredict(model, xtest);

figure;
plot(X, y, 'o', 'markersize', 10); hold on
plot(xtest, mu, 'r-', 'linewidth', 3);
title(sprintf('predicted mean, fixed mixing weights=%d', fixmix))
printPmtkFigure(sprintf('mixexpMeanFixmix%d', fixmix))

figure; plot(X, y, 'o', 'markersize', 10); hold on
plot(xtest, mu, 'r-', 'linewidth', 3);
N = numel(xtest); ndx = 1:4:N;
errorbar(xtest(ndx), mu(ndx), sqrt(v(ndx)));
title(sprintf('predicted mean and var, fixed mixing weights=%d', fixmix))
printPmtkFigure(sprintf('mixexpMeanVarFixmix%d', fixmix))


%colors = pmtkColors;
[styles, colors, symbols, str] = plotColors;

figure; hold on
for k=1:K
  str = sprintf('%s%s', styles{k}, colors(k));
  plot(xtest, post(:,k), str,  'linewidth', 3);
end
title(sprintf('gating functions, fixed mixing weights=%d', fixmix))
axis_pct
printPmtkFigure(sprintf('mixexpGatingFixmix%d', fixmix))


figure; hold on
for k=1:K
  str = sprintf('%s%s', styles{k}, colors(k));
  plot(xtest, muk(:,k), str,  'linewidth', 3);
end
plot(X, y, 'o', 'markersize', 10); 
title(sprintf('expert predictions, fixed mixing weights=%d', fixmix))
printPmtkFigure(sprintf('mixexpExpertsFixmix%d', fixmix))


end

placeFigures
