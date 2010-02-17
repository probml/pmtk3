% Sparse linear regression with EM on synthetic data
% Similar to fig 8 from "Sparse Bayesian nonparametric regression",
% Caron and Doucet, ICML08
% We do not include normalInverseGaussian
% but we do include normalExpGaussian

close all
clear all
setSeed(0);

D=100; % Number of coefficients to estimate
rho=.5; % Correlation
for i=1:D
   for j=1:D
       correl(i,j)=rho^(abs(i-j));
   end
end
C  = chol(correl);
sparsities = [0.02 0.05];
for sparsityNdx=1:length(sparsities)
   sparsity = sparsities(sparsityNdx);
   
for trial=1:3
   nnz = ceil(D*sparsity);
   ndx = unidrnd(D,1,nnz);
   w_true = zeros(D,1);
   w_true(ndx) = 1*randn(nnz,1);
   
   Ntrain = 100;
   Ntest = 10000;
   sigmaTrue = 1;
   Xtrain=randn(Ntrain,D)*C; 
   ytrain=Xtrain*w_true + sigmaTrue*randn(Ntrain,1); % Vector of observations
   Xtest=randn(Ntest,D)*C; 
   ytest=Xtest*w_true + sigmaTrue*randn(Ntest,1); % Vector of observations
    
   [ytrain, muY, sY] = standardizeCols(ytrain);
   ytest = standardizeCols(ytest, muY, sY);
   
   [Xtrain, mu] = center(Xtrain);
   Xtest = center(Xtest, mu);
   
   priors = {'ridge',  'NG', 'NJ', 'laplace'}; % neg too slow
   for m=1:length(priors)
      prior = priors{m};
      switch lower(prior)
        case 'nj'
          scales = 1; shapes = 1; % dummy values
        case {'laplace','ridge'}
          scales = [0.001 0.01 0.1 1 10];
          shapes = 1;
        case {'ng', 'neg'},
         scales = [0.001 0.01 0.1 1 10];
         shapes=[0.01 0.1 1];
      end
      params = crossProduct(scales, shapes);
      Nfolds=3;
      useSErule = false;
      options = {'maxIter', 15, 'verbose', false};
      fitFn = @(X,y,ps) linregFitSparseEm(X,y, prior, ps(1), ps(2), sigmaTrue, options{:});
      predictFn = @(w, X) X*w;
      lossFn = @(yhat, y)  sum((yhat-y).^2);
      [w, kstar, mu, se] = fitCv(params, fitFn, predictFn, lossFn, Xtrain, ytrain,  Nfolds, useSErule);
      
      % refit model more carefully with best params and all the data
      scale = params(kstar, 1);
      shape = params(kstar, 2);
      options = {'maxIter', 30, 'verbose', true};
      [w, sigmaHat, logpostTrace] = linregFitSparseEm(Xtrain, ytrain,  prior, scale, shape, sigmaTrue, options{:});
      mse(m) = mean((ytest-Xtest*w).^2);
      mseTrial(trial,m) = mse(m);
      
      if ~strcmpi(prior, 'ridge')
        figure(m); clf; plot(logpostTrace, 'o-');
        str = sprintf('%s, scale=%5.3f, shape=%5.3f\n',   prior, scale, shape);
        title(sprintf('%s, trial %d, sparsity %5.3f', str, trial, sparsity))
      end
   end % for m
   
end % for trial

figure;
boxplot(mseTrial, 'labels', priors)
title(sprintf('mse on test for D=%d, Ntrain=%d, sparsity=%3.2f', D, Ntrain, sparsity))
printPmtkFigure(sprintf('linregSparseEm2SynthBoxplot%d', sparsityNdx))

end % sparsityNdx
