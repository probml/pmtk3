%% PCA test set reconstruction error vs likelihood as K increases
% Show that reconstruction error on test set gets lower
% as K increases for PCA, but likelihood for PPCA has U shaped curve
%PMTKslow
%%
setSeed(0);

%load('olivettifaces.mat'); % 0 to 255, from http://www.cs.toronto.edu/~roweis/data.html
%X=faces'; clear faces; % 4096x400  (64x64=4096)

if 1
  load('mnistALL.mat'); % mnist structure
  %train_images: [28x28x60000 uint8]  0 to 255
  %   test_images: [28x28x10000 uint8]
  %  train_labels: [60000x1 uint8]
  %   test_labels: [10000x1 uint8]
  h = 28; w = 28; d= h*w;
  ndx = find(mnist.train_labels==3);
  ndx = ndx(1:1000); n = length(ndx); 
  X = double(reshape(mnist.train_images(:,:,ndx),[d n]))';
  name = 'mnist3'
end

n = size(X,1)
n2 = floor(n/2);
X = centerCols(X);
Xtrain = X(1:n2,:);
Xtest = X((n2+1):end,:);

Ks = round(linspace(1, rank(Xtrain), 5))
for ki=1:length(Ks)
  k = Ks(ki);
  [V] = pcaPmtk(Xtrain, k);
  Ztest = Xtest*V;
  XtestRecon = Ztest*V';
  err = (XtestRecon - Xtest);
  mse(ki) = sqrt(mean(err(:).^2));
  
  [W,mu,sigma2,evals,evecs]  = ppcaFit(Xtrain,k);  
  [logp] = ppcaLoglik(Xtest, W, mu, sigma2, evals, evecs);
  ll(ki) = sum(logp);
end

figure;
plot(Ks, mse(1:length(Ks)), '-o', 'linewidth', 3, 'markersize', 12)
ylabel('mse'); xlabel('K');
title('test set reconstruction error');
printPmtkFigure('pcaVsKrecon')
 
figure;
plot(Ks, -ll, '-o', 'linewidth', 3, 'markersize', 12)
ylabel('negloglik'); xlabel('K'); 
title('test set negative loglik');
printPmtkFigure('pcaVsKnll')
 




