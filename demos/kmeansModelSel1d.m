%% Kmeans Model Selection in 1D
% Uses netlab since haven't had time to switch over to pmtk
%%

% This file is from pmtk3.googlecode.com

clear all
setSeed(0);
mix = gmm(1, 3, 'spherical'); 
mix.centres = [-1 0 1]';
mix.covars = [0.1 0.1 0.1];
%e = 1e-2; e2 = e/2;
%mix.priors = [0.5-e2, 0.5-e2, e];

bins = -2:0.1:2;
n = 1000; ndx = 1:n;
Xtrain = gmmsamp(mix, n);

figure;
hist(Xtrain, bins);
title('Xtrain')
printPmtkFigure kmeansModelSel1dTrain


Xtest = gmmsamp(mix, n);

figure
hist(Xtest, bins);
title('Xtest')
printPmtkFigure kmeansModelSel1dTest

%Ks = [1:9];
%Ks = [1 2 3 4 5  10 15 20 25];
Ks = [2 3 4 5 6 10 15];

%% Kmeans

%Fit the  models
for i=1:length(Ks)
  K = Ks(i);
  mu = kmeansFit(Xtrain, K)';
  Xhat = kmeansDecode(kmeansEncode(Xtest, mu'), mu');
  mus{i} = mu;
end

%Evaluate reconstruciton error on test set
for i=1:length(Ks)
  K = Ks(i);
  mu = mus{i};
  Xhat = kmeansDecode(kmeansEncode(Xtest, mu'), mu');
  mse(i) = mean(sum((Xhat - Xtest).^2,2));
end


% Plot error
figure;
plot(Ks, mse, 'o-', 'linewidth', 2);
title('MSE on test vs K for K-means')
printPmtkFigure kmeansModelSel1d-kmeans-mse


% Plot the parameters
figure;
for i=1:6
  mu = mus{i}; K = Ks(i);
  subplot(2,3,i);
  for k=1:K
    h=line([mu(k) mu(k)], [0 1]);
    set(h, 'color', 'r', 'linewidth', 3);
    hold on
  end
  title(sprintf('K=%d, mse=%5.4f', K, mse(i)))
end
printPmtkFigure kmeansModelSel1d-kmeans-mu


%% GMM

% Fit the GMM
options = foptions;
for i=1:length(Ks)
  K = Ks(i);
  mix = gmm(1, K, 'spherical');
  % Initialize to Kmeans solution
  mix.centres = mus{i};
  mix = gmmem(mix, Xtrain, options);
  models{i} = mix;
end

% Evlauate the NLL
for i=1:length(Ks)
  K = Ks(i);
  mix = models{i};
  nll(i) = -sum(log(gmmprob(mix, Xtest)));
end

% Plot the NLL
figure;
plot(Ks, nll, 'o-', 'linewidth', 2)
title('NLL on test set vs K for GMM')
printPmtkFigure kmeansModelSel1d-gmm-NLL

% Plot the predictive density
figure;
finebins = -2:0.001:2;
for i=1:6
  mix = models{i};
  subplot(2,3,i);
  K = Ks(i);
  pmodel = gmmprob(mix, finebins(:));
  plot(finebins, pmodel, '-', 'linewidth', 2);
  title(sprintf('K=%d, nll=%5.4f', K, nll(i)))
end
printPmtkFigure kmeansModelSel1d-gmm-density


%Evaluate reconstruciton error on test set
for i=1:length(Ks)
  K = Ks(i);
  mu = models{i}.centres;
  Xhat = kmeansDecode(kmeansEncode(Xtest, mu'), mu');
  msegmm(i) = mean(sum((Xhat - Xtest).^2,2));
end

% Plot error
figure;
plot(Ks, msegmm, 'o-', 'linewidth', 2);
title('MSE on test vs K for GMM')
printPmtkFigure kmeansModelSel1d-gmm-mse


% Plot the parameters
figure;
for i=1:6
 K = Ks(i);
  subplot(2,3,i);
  for k=1:K
       mu = models{i}.centres(k);
    h=line([mu mu], [0 1]);
    set(h, 'color', 'r', 'linewidth', 3);
    hold on
  end
  title(sprintf('K=%d, mse=%5.4f', K, mse(i)))
end
printPmtkFigure kmeansModelSel1d-gmm-mu

% Plot the individual Gaussians
figure;
for i=1:6
   K = Ks(i);
  subplot(2,3,i);
  for k=1:K
      mu = models{i}.centres(k);
      sigma = sqrt(models{i}.covars(k));
     pmodel = normpdf(finebins(:), mu, sigma);
     plot(finebins, pmodel, '-', 'linewidth', 2);
    hold on
  end
  title(sprintf('K=%d, mse=%5.4f', K, mse(i)))
end
printPmtkFigure kmeansModelSel1d-gmm-components





