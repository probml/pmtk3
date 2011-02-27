%% Sparse linear regression with EM on synthetic data
% PMTKreallySlow
% PMTKneedsStatsToolbox boxplot
%%

% This file is from pmtk3.googlecode.com

requireStatsToolbox
setSeed(0);

D=200; % Number of coefficients to estimate
rho=.5; % Correlation
for i=1:D
   for j=1:D
       correl(i,j)=rho^(abs(i-j));
   end
end
C  = chol(correl);
sparsities = [0.05 0.25];
for sparsityNdx=1:length(sparsities)
   sparsity = sparsities(sparsityNdx);
   
for trial=1:3
   nnz = ceil(D*sparsity);
   ndx = unidrndPMTK(D,1,nnz);
   w_true = zeros(D,1);
   w_true(ndx) = randn(nnz,1);
   
   if 0 % trial==1
   figure;
   %stem(w_true)
   stem(w_true, 'marker','none')
   box off
   title(sprintf('true weights on trial %d, nnz=%d', trial, nnz))
   printPmtkFigure(sprintf('linregSparseEmSynthWeightsTrue%d', sparsityNdx))
   end
   
   Ntrain = 0.5*D;
   Ntest = 10*D;
   Xtrain=randn(Ntrain,D)*C; % Matrix of regressors
   ytrain=Xtrain*w_true+1*randn(Ntrain,1); % Vector of observations
   Xtest=randn(Ntest,D)*C; % Matrix of regressors
   ytest=Xtest*w_true+1*randn(Ntest,1); % Vector of observations
   
  
   [ytrain, muY, sY] = standardizeCols(ytrain);
   ytest = standardizeCols(ytest, muY, sY);
   
   [Xtrain, mu] = centerCols(Xtrain);
   Xtest = centerCols(Xtest, mu);
   
   options = {'maxIter', 100, 'verbose', false};
   models = {'ridge', 'normaljeffreys', 'normalgamma', 'normalinversegaussian', 'laplace'};
   names= {'ridge', 'NJ', 'NG', 'NIG', 'Laplace'};
   for m=1:length(models)
      clear param
      param.model = models{m};
      % use CV to pick hyper params
      if strcmp(param.model, 'normaljeffreys')
         c_trial = [1]; % dummy value
      else
         c_trial= [0.001 0.01 0.1 1 10];
         %c_trial= [.0001:.1:1];
      end
      if ismember(param.model, {'laplace', 'normaljeffreys', 'ridge'})
         alpha_trial = [1]; % dummy value
      else
         alpha_trial=[.1 1 5 10];
      end
      if ismember(param.model, {'ridge'})
         sigma_trial = [1]; % dummy
      else
         sigma_trial=[.1 .5 1]; % starting values for EM
      end
      Nfolds=3;
      clear errMean
      for ndx1 = 1:length(c_trial)
         for ndx2 = 1:length(alpha_trial)
            for ndx3 = 1:length(sigma_trial)
               param.c = c_trial(ndx1);
               param.alpha = alpha_trial(ndx2);
               param.sigma = -sigma_trial(ndx3);
               tmpOptions = {'maxIter', 30, 'verbose', false};
               fitFn = @(X,y) linregFitSparseEmFrancois(X,y, param, tmpOptions{:});
               predictFn = @(w, X) X*w;
               lossFn = @(yhat, y)  sum((yhat-y).^2);
               [errMean(ndx1,ndx2,ndx3), se] = cvEstimate(fitFn, predictFn, lossFn, Xtrain, ytrain,  Nfolds);
            end
         end
      end
      % Pick best then refit with all training data
      err = errMean(:);
      [minErr, bestNdx] = min(err);
      [ndx1, ndx2, ndx3] = ind2sub([length(c_trial), length(alpha_trial), length(sigma_trial)], bestNdx);
      param.c = c_trial(ndx1);
      param.alpha = alpha_trial(ndx2);
      param.sigma = -sigma_trial(ndx3);
      fprintf('CV %s best c=%5.3f, alpha=%5.3f, sigma = %5.3f\n', ...
         param.model, param.c, param.alpha, param.sigma);
      [param.w, param.sigma, logpostTrace{m}] =  linregFitSparseEmFrancois(Xtrain, ytrain, param, options{:});
      params{m} = param;
      errSurface{m} = errMean;
      w = param.w;
      mse(m) = mean((ytest-Xtest*w).^2);
      mseTrial(trial,m) = mse(m);
      
      %figure; plot(-logpostTrace{m}); title(names{m})
   end % for m
   
   % null model
   %w=zeros(size(Xtrain,2),1);
   %mse(end+1)=mean((ytest-Xtest*w).^2);
   
   
   %% plot results
   
   figure;
   bar(mse);
   set(gca,'xticklabel',names)
   title(sprintf('mse test on trial %d, sparsity %5.3f', trial,sparsity))
   
   if 0 % trial==1
      for m=1:length(params)
         param = params{m};
         w = param.w;
         figure;
         stem(w, 'marker','none')
         box off
         title(sprintf('weights for %s, sparsity %5.3f',names{m}, sparsity))
         printPmtkFigure(sprintf('linregSparseEmSynthWeights%s%d', names{m}, sparsityNdx))
      end
   end
   
end % for trial

figure;
boxplot(mseTrial, 'labels', names)
title(sprintf('mse on test for D=%d, Ntrain=%d, sparsity=%3.2f', D, Ntrain, sparsity))
printPmtkFigure(sprintf('linregSparseEmSynthBoxplot%d', sparsityNdx))

end % sparsityNdx
