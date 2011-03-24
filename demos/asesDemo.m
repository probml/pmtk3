% This is a simplified version of discreteDensityModelsShootout
% We fit 3 models to the ASES data and assess imputation performance
% Independent (multinoulli product) model
% Mixture of multinoulli products
% Categorical factor analysis using Bohning bound

%% Data
% labels is N*D, where labels(n,d) in {1..Nstates(d)}


Nfolds = 1;
% pcTrain and pcTest do not need to sum to one
% This way, you can use a fraction of the overall data
pcTrain = 0.5; pcTest = 0.5;
pcMissing =  0.5;

dataName = 'ases';

%a = importdata([dirName 'asesLarge.txt']);
%Y = a.data;
load('ases.mat'); % Y is 18243x43, names 1x53 cell
%  remove rows with any missing values
idx = find(~sum(isnan(Y),2));
X = Y(idx,:); % 8735 * 53
% take a specific country
name = 'ases';
switch name
  case 'ases'
    idx = find(X(:,2) == 2);
  case 'asesUK'
    idx = find(X(:,1) == 10);
  case 'asesFrance'
    idx = find(X(:,1) == 12);
  case 'asesGermany'
    idx = find(X(:,1) == 13);
  case 'asesDeveloping'
    idx = find(X(:,1) == 1);
  case 'asesDeveloped'
    idx = find(X(:,2) == 2);
end
X = X(idx,:);
labels = X(:,[3:44]);
names = names(3:44);
nClass = max(labels,[],1);
% currently the code assumes all nodes have the same #values
% So we extract features
ndx = find(nClass==4);
labels = labels(:, ndx); % 5347 * 17
names = names(ndx);
nodeNames = names;
Nstates = 4*ones(1,numel(nodeNames));
isbinary =  all(Nstates==2)


%% Models/ methods

methods = [];
m = 0;

  
m = m + 1;
methods(m).modelname = 'indep';
methods(m).fitFn = @(labels) discreteFit(labels);
methods(m).logprobFn = @(model, labels) discreteLogprob(model, labels);
methods(m).predictMissingFn = @(model, labels) discretePredictMissing(model, labels);




m = m + 1;
methods(m).modelname = 'mix40';
methods(m).fitFn = @(labels) mixModelFit(labels, 40, 'discrete', 'maxIter', 20, 'verbose', false);
methods(m).logprobFn = @(model, labels) mixModelLogprob(model, labels);
methods(m).predictMissingFn = @(model, labels) mixModelPredictMissing(model, labels);



m = m + 1;
methods(m).modelname = 'mix60';
methods(m).fitFn = @(labels) mixModelFit(labels, 60, 'discrete', 'maxIter', 20, 'verbose', false);
methods(m).logprobFn = @(model, labels) mixModelLogprob(model, labels);
methods(m).predictMissingFn = @(model, labels) mixModelPredictMissing(model, labels);



m = m + 1;
methods(m).modelname = 'mix80';
methods(m).fitFn = @(labels) mixModelFit(labels, 80, 'discrete', 'maxIter', 20, 'verbose', true);
methods(m).logprobFn = @(model, labels) mixModelLogprob(model, labels);
methods(m).predictMissingFn = @(model, labels) mixModelPredictMissing(model, labels);



m = m + 1;
methods(m).modelname = 'catFA-50';
methods(m).fitFn = @(labels) catFAfit(labels, [],  50,  'nlevels', Nstates, 'maxIter', 200, 'verbose', true);
methods(m).logprobFn = @(model, labels) argout(3, @catFAinferLatent, model, labels, []);
methods(m).predictMissingFn = @(model, labels) catFApredictMissing(model, labels, []);


m = m + 1;
methods(m).modelname = 'catFA-100';
methods(m).fitFn = @(labels) catFAfit(labels, [],  100,  'nlevels', Nstates, 'maxIter', 200, 'verbose', true);
methods(m).logprobFn = @(model, labels) argout(3, @catFAinferLatent, model, labels, []);
methods(m).predictMissingFn = @(model, labels) catFApredictMissing(model, labels, []);


Nmethods = numel(methods);


%% CV
setSeed(0);
N = size(labels, 1)
if Nfolds == 1
  % it is important to shuffle the rows to eliminate ordering effects
  % (the newsgroup data is sorted by category)
  perm = randperm(N);
  stop = floor(N*pcTrain);
  trainfolds{1}  = perm(1:stop);
  stop2 = floor(N*pcTest);
  testfolds{1} = perm(stop+1: stop+stop2);
  
  %trainfolds{1} = 1:N;
  %testfolds{1} = 1:N;
  
  % For speed, use a small set of data
  %trainfolds{1} = perm(1:5000);
  %testfolds{1} = perm(5000:8000); %trainfolds{1};
else
  randomize = true;
  [trainfolds, testfolds] = Kfold(N, Nfolds, randomize);
end

loglik_models = zeros(Nfolds, Nmethods);
imputation_err_models = zeros(Nfolds, Nmethods);
 

for fold=1:Nfolds

  train.labels = labels(trainfolds{fold}, :);
  test.labels = labels(testfolds{fold}, :);
  [Ntrain, Nnodes] = size(train.labels);
  [Ntest, Nnodes2] = size(test.labels);
  
  fprintf('fold %d of %d, Ntrain %d, Ntest %d\n', ...
    fold, Nfolds, Ntrain, Ntest);
 
  
  missingMask = rand(Ntest, Nnodes) >= (1-pcMissing);
  test.labelsMasked = test.labels;
  test.labelsMasked(missingMask) = nan;
 
  
  models = cell(1, Nmethods);
  methodNames = cell(1, Nmethods);
  for m=1:Nmethods
    methodNames{m} = sprintf('%s', methods(m).modelname); 
    fprintf('fitting %s\n', methodNames{m});
    models{m} = methods(m).fitFn(train.labels);
  end
  

  ll = zeros(1, Nmethods);
  imputationErr = zeros(1,Nmethods);
  for m=1:Nmethods
    fprintf('evaluating %s\n', methodNames{m});
    ll(m) = sum(methods(m).logprobFn(models{m}, test.labels))/Ntest;
    
    if isfield(methods(m), 'predictMissingFn')
      pred = methods(m).predictMissingFn(models{m}, test.labelsMasked);
      % for binary data - MSE is fine
      %probOn = pred(:,:,2);  
      %imputationErr(m) = sum(sum((probOn-test.tags).^2))/Ntest; 
      
      % for K-ary data - MSE not so meaningful
      % so we use cross entropy
      [~,truth3d] = dummyEncoding(test.labels, Nstates);
      %imputationErr(m) = sum(sum(sum((truth3d-pred).^2)))/Ntest;
      %logprob = sum(sum(log(sum(truth3d .* pred, 3))))/Ntest;
      
      % Just assess performance on the missing entries
      % This does not affect the relative performance of methods
      logprob = log(sum(truth3d .* pred, 3)); % N*D
      logprobAvg = sum(sum(logprob(missingMask)))/sum(missingMask(:));
       
      imputationErr(m) = -logprobAvg;
    end
  end
  loglik_models(fold, :) = ll;
  imputation_err_models(fold, :) = imputationErr;
  
end % fold



%% Plot performance


% imputation error
figure;
ndx = 2:Nmethods % exclude indep
if Nfolds==1
  plot(imputation_err_models(ndx), 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  boxplot(imputation_err_models(:, ndx))
end
set(gca, 'xtick', 1:numel(ndx))
set(gca, 'xticklabel', methodNames(ndx))
%xticklabelRot(methodNames(ndx), -45);
title(sprintf('imputation error on %s with %5.3f percent missing', ...
  dataName, pcMissing))
