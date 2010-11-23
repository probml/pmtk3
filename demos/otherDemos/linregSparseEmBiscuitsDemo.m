%% Sparse linear regression with EM on biscuits data
% PMTKreallySlow
%%

% This file is from pmtk3.googlecode.com



loadData('biscuits');
ings = [1:4]; % fat, sucrose, flour, water
for dim=1:length(ings)
   ing = ings(dim);

Xtrain = A_train;
Xtest = A_test;
ytrain = y_train(:, ing);
ytest = y_test(:, ing);
[N,D] = size(Xtrain);

[ytrain, muY, sY] = standardizeCols(ytrain);
ytest = standardizeCols(ytest, muY, sY);

[Xtrain, mu] = centerCols(Xtrain);
Xtest = centerCols(Xtest, mu);

options = {'maxIter', 200, 'verbose', false};
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
   [param.w] =  linregFitSparseEmFrancois(Xtrain, ytrain, param, options{:});
   params{m} = param;
   errSurface{m} = errMean;
   w = param.w;
   mse(m) = mean((ytest-Xtest*w).^2);
end

% null model
%w=zeros(size(Xtrain,2),1);
%mse(end+1)=mean((ytest-Xtest*w).^2);


%% plot results
%{
figure;
bar(mse);
set(gca,'xticklabel',names)
title(sprintf('mse test on %s', ingredients{ing}))
%}

figure;
sse = mse*length(ytest);
bar(sse)
set(gca,'xticklabel',names)
title(sprintf('sse test on %s', ingredients{ing}))
drawnow

if 0
for m=1:length(params)
   param = params{m};
   w = param.w;
   figure('name',param.model)
   title(param.model)
   stem(spectrum, w, 'marker','none')
   xlabel('Wavelength (nm)')
   ylabel('coef')
   box off
   
   figure('name',param.model)
   title(param.model)
   plot(Xtrain*w,ytrain,'+')
   hold on
   plot(Xtest*w,ytest,'og')
   plot(-5:5,-5:5,'--r')
   xlim([-3 3])
   ylim([-3 3])
   legend('Training data','Test data','location','Northwest')
   xlabel('Predicted observations')
   ylabel('Observations')
   box off
end
end

end % for dim


