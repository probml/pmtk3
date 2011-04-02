 
dataFolder = '/home/kpmurphy/scratch/wasabiLabelme/data';
figFolder = '/home/kpmurphy/scratch/wasabiLabelme/figures';


%% Get Data
setSeed(0);
loadData('sceneContextSUN09', 'ismatfile', false)
load('SUN09data')

[Ntrain Nobjects] = size(data.train.presence);
objectnames = data.names;
Ntest = size(data.test.presence,1);
presence = [data.train.presence; data.test.presence];
detect_maxprob = [data.train.detect_maxprob; data.test.detect_maxprob];
filenames = [data.train.filenames data.test.filenames];
N = size(presence, 1);
Nfolds = 1;
if Nfolds == 1
  % use original train/ test split
  trainfolds{1} = 1:Ntrain;
  %Ntest = 1000; % use subset of test data for speed
  testfolds{1} = (Ntrain+1):(Ntrain+Ntest);
  
  % use subset of training set - dgm should have
  % higher likelihood since more complex model
  %testfolds{1} = 1:10;
else
  randomizeOrder = true;
  [trainfolds, testfolds] = Kfold(N, Nfolds, randomizeOrder);
end

fold = 1;

train.presence = presence(trainfolds{fold}, :);
train.detect_maxprob = detect_maxprob(trainfolds{fold}, :);
test.presence = presence(testfolds{fold}, :);
test.detect_maxprob = detect_maxprob(testfolds{fold}, :);
test.filenames = filenames(testfolds{fold});

[Ntrain, Nobjects] = size(train.presence);
[Ntest, Nobjects2] = size(test.presence);

%% Train  p(scores | labels)
%[obsmodelGauss] = obsModelFit(train.presence, train.detect_maxprob, 'gauss');
%softevBatchGauss = obsModelEval(obsmodelGauss, test.detect_maxprob);

Nnodes = Nobjects;
Nstates = 2;
model.mu = zeros(Nstates, Nnodes);
model.Sigma = zeros(Nstates, Nnodes);
labels = train.presence;
features = train.detect_maxprob;
for j=1:Nnodes
  Z = canonizeLabels(labels(:,j)); 
  ss = 0;
  for k=1:Nstates
    ndx = (Z==k);
    model.mu(k, j) = mean(features(ndx, j));
    model.Sigma(k,j) = var(features(ndx, j), 1);
    ss = ss + sum( (features(ndx,j) - model.mu(k,j)) .^2 );
  end
  model.SigmaPooled(j) = ss / size(features, 1); 
end

features = test.detect_maxprob;
softev = zeros(Nstates, Nnodes, Ntest);
for t=1:Nnodes
  for k=1:Nstates
    mu = model.mu(k,t);
    %Sigma = model.Sigma(k,t);
    Sigma = model.SigmaPooled(t);
    softev(k,t,:)  = reshape(gaussLogprob(mu, Sigma, features(:,t)), [1 1 Ntest]);
  end
  softevt = permute(softev(:,t,:), [1 3 2])'; % N*K
  %softevt = exp(normalizeLogspace(softevt));
  softevt = exp(softevt);
  softev(:,t,:) = softevt'; % N*1*K
end
softevBatchGauss = softev;
%softevBatchGauss = normalize(softevBatchGauss, 1);

% Compare raw scores to process scores
figure; ndx=40:50; c=1;
stem(features(ndx,c), 'r-'); title('raw scores');
figure;
stem(squeeze(softevBatchGauss(2,c,ndx)), 'b:')
title('gauss scores')


%% Baselines
presence_model = zeros(Ntest, Nobjects, 2);  
presence_model(:, :, 1) = test.detect_maxprob;
presence_model(:, :, 2) =  permute(softevBatchGauss(2, :, :), [3 2 1]);
methodNames = {'det-raw', 'det-gauss'};

%% Read in scores of wasabi methods
%{
fileNames = setdiff(dirPMTK(dataFolder), 'figures')
Nfiles = numel(fileNames);
wasabiScores = zeros(Ntest, Nobjects, Nfiles);
for m=1:Nfiles
  fname = fullfile(dataFolder, fileNames{m});
  shortNames{m} = fileNames{m}(1:end-length('results.'));
  wasabiScores(:,:,m) = load(fname); % read text file
end
methodNames = [methodNames shortNames];
presence_model = cat(3, presence_model, wasabiScores);
%}


Nmethods = numel(methodNames);


%% Performance evaluation
mean_auc_models = zeros(Nfolds, Nmethods);
mean_eer_models = zeros(Nfolds, Nmethods);
auc_models = nan(Nobjects, Nmethods);
eer_models = nan(Nobjects, Nmethods);
absent = zeros(1, Nobjects);
for c=1:Nobjects
  % If the object is absent in a given fold, we may get NaN for
  % the performance. We want to exclude these from the evaluation.
  absent(c) = all(test.presence(:,c)==0);
  if absent(c), continue; end
  for m=1:Nmethods
    [auc_models(c,m), fpr, tpr,  eer_models(c,m)] = ...
      rocPMTK(presence_model(:,c,m), test.presence(:,c)); %#ok
  end
end
if any(absent)
  fprintf('warning: in fold %d of %d, %s are absent from test\n', ...
    fold, Nfolds, sprintf('%s,', objectnames{find(absent)}));
end
for m=1:Nmethods
  mean_auc_models(fold,m) = mean(auc_models(~absent,m));
  mean_eer_models(fold,m) = mean(eer_models(~absent,m));
end




%% Plotting

[styles, colors, symbols, plotstr] =  plotColors();


% Mean AUC
ndx = 1:Nmethods;
figure;
if Nfolds==1
  plot(mean_auc_models, 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  boxplot(mean_auc_models(:, ndx));
end
set(gca, 'xtick', 1:numel(ndx))
%set(gca, 'xticklabel',  methodNames(ndx))
xticklabelRot(methodNames(ndx), 45)
title(sprintf('AUC averaged over classes'))
fname = fullfile(figFolder, sprintf('wasabi-auc.png'));
print(gcf, '-dpng', fname);
  
% Mean EER
figure;
if Nfolds==1
  plot(mean_eer_models, 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  boxplot(mean_eer_models(:,ndx))
end
set(gca, 'xtick', 1:numel(ndx))
xticklabelRot(methodNames(ndx), 45)
%set(gca, 'xticklabel', methodNames(ndx))
title(sprintf('EER averaged over classes'))
fname = fullfile(figFolder, sprintf('wasabi-eer.png'));
print(gcf, '-dpng', fname);
  
for i=1:Nmethods
  fprintf('%s\n', methodNames{i});
end


 