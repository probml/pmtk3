 

%% Data
loadData('sceneContextSUN09', 'ismatfile', false)
load('SUN09data')
objectnames  = data.names;

figFolder = '/home/kpmurphy/Dropbox/figures/sceneContext';

%% Models/ methods

methods = [];
m = 0;

m = m + 1;
methods(m).modelname = 'indep';
methods(m).obstype = 'detector';
methods(m).fitFn = @(labels, features) discreteFit(labels);
methods(m).infFn = @(model, features, softev) softev; % just spit back detector
methods(m).logprobFn = @(model, labels) discreteLogprob(model, labels);

%{
%[logZ, nodeBel] = treegmInferNodes(treeModel, localFeatures, softev);
m = m + 1;
methods(m).modelname = 'tree';
methods(m).obstype = 'gauss';
methods(m).fitFn = @(labels, features) treegmFit(labels);
methods(m).infFn = @(model, features, softev) argout(2, @treegmInferNodes, model, [], softev);
methods(m).logprobFn = @(model, labels) treegmLogprob(model, labels);
%}

%[pZ, pX] = noisyMixModelInferNodes(mixModel{ki}, localFeatures, softev);
m = m + 1;
methods(m).modelname = 'mix5';
methods(m).obstype = 'gauss';
methods(m).fitFn = @(labels, features) noisyMixModelFit(labels, [], 5);
methods(m).infFn = @(model, features, softev) argout(2, @noisyMixModelInferNodes, model, [], softev);
methods(m).logprobFn = @(model, labels) mixModelLogprob(model.mixmodel, labels);

%{
m = m + 1;
methods(m).modelname = 'dag';
methods(m).obstype = 'gauss';
methods(m).fitFn = @(labels, features) dgmFit(labels);
methods(m).infFn = @(model, features, softev) argout(2, @dgmInferNodes, model, [], softev);
methods(m).logprobFn = @(model, labels) dgmLogprob(model, labels);
%}


Nmethods = numel(methods);


%% CV

setSeed(0);
[Ntrain Nobjects] = size(data.train.presence);
objectnames = data.names;
Ntest = size(data.test.presence,1);
presence = [data.train.presence; data.test.presence];
detect_maxprob = [data.train.detect_maxprob; data.test.detect_maxprob];
filenames = [data.train.filenames data.test.filenames];
N = size(presence, 1);
assert(N==Ntrain+Ntest);
Nfolds = 1;
if Nfolds == 1
  % use original train/ test split
  trainfolds{1} = 1:Ntrain;
  testfolds{1} = (Ntrain+1):(Ntrain+Ntest);
else
  [trainfolds, testfolds] = Kfold(N, Nfolds);
end

% These are the performance measures which we store
mean_auc_models = zeros(Nfolds, Nmethods);
mean_eer_models = zeros(Nfolds, Nmethods);
loglik_models = zeros(Nfolds, Nmethods);
  
fprThresh = 0.05; % used to decide what labels to plot

for fold=1:Nfolds
  fprintf('fold %d of %d\n', fold, Nfolds);
  train.presence = presence(trainfolds{fold}, :);
  train.detect_maxprob = detect_maxprob(trainfolds{fold}, :);
  test.presence = presence(testfolds{fold}, :);
  test.detect_maxprob = detect_maxprob(testfolds{fold}, :);
  test.filenames = filenames(testfolds{fold});
  
  [Ntrain, Nobjects] = size(train.presence);
  [Ntest, Nobjects2] = size(test.presence);
  
  %% Train  p(scores | labels)
  
  labels = train.presence;
  scores = train.detect_maxprob;
  %[quantizedScores, discretizeParams] = discretizePMTK(scores, 10);
  [obsmodelGauss] = obsModelFit(labels, scores, 'gauss');
  
  
  %% Training p(labels)
  
  models = cell(1, Nmethods);
  for m=1:Nmethods
    methodNames{m} = sprintf('%s-%s', methods(m).modelname, methods(m).obstype); %#ok
    fprintf('fitting %s\n', methodNames{m});
    models{m} = methods(m).fitFn(labels, scores);
  end
  
  
  
  %% Probability of labels
  ll = zeros(Ntest, Nmethods);
  labels = test.presence+1; % 1,2
  for m=1:Nmethods
    ll(:, m) = methods(m).logprobFn(models{m}, labels);
  end
  loglik_models(fold, :) = sum(ll, 1)/Ntest;
  
  
  %% Inference
  presence_model = zeros(Ntest, Nobjects, Nmethods);  
  features = test.detect_maxprob; %Ncases*Nnodes*Ndims
  % as a speedup, we compute soft evidence from features in batch form
  softevBatchGauss = obsModelEval(obsmodelGauss, features);
  %[quantizedScores, discretizeParams] = discretizePMTK(scores, 10);
  
  for m=1:Nmethods
    fprintf('running method %s\n', methodNames{m});
    
    for n=1:Ntest
      if (n==1) || (mod(n,500)==0), fprintf('testing image %d of %d\n', n, Ntest); end
      switch methods(m).obstype
        case 'detector'
          softev = zeros(2, Nobjects);
          softev(1, :) = 1-test.detect_maxprob(n,:);
          softev(2, :) = test.detect_maxprob(n,:);
          bel = methods(m).infFn(models{m}, [], softev);
        case 'gauss'
          softev = softevBatchGauss(:, :, n);
          % hack to prevent too many false positives: 
          % if detector doesn't fire, don't hallucinate objects
          % by setting soft evidence for the on state to be hard 0
          ndx = find(test.detect_maxprob(n,:) < 1e-5);
          softev(2, ndx) = 0;
          bel = methods(m).infFn(models{m}, [], softev);
      end
      probPresent = bel(2,:);
      presence_model(n,:,m) = probPresent;
    end % for n
  end % for m
  
  %% Performance evaluation
  
  % We compute the area under the ROC curve, the equal error rate
  % and the cutoff/ threshold that achieves EER
  auc_models = nan(Nobjects, Nmethods);
  eer_models = nan(Nobjects, Nmethods);
  cutoff_eer = nan(Nobjects, Nmethods);
  cutoff_fpr = nan(Nobjects, Nmethods);
  absent = zeros(1, Nobjects);
  for c=1:Nobjects
    % If the object is absent in a given fold, we may get NaN for
    % the performance. We want to exclude these from the evaluation.
    absent(c) = all(test.presence(:,c)==0);
    if absent(c), continue; end
    for m=1:Nmethods
      [auc_models(c,m), fpr, tpr,  eer_models(c,m), cutoff_eer(c,m), ...
        tprAtThresh, fprAtThresh, cutoff_fpr(c,m)] = ...
        rocPMTK(presence_model(:,c,m), test.presence(:,c), fprThresh); %#ok
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
  
end % fold



%% Plotting

[styles, colors, symbols, plotstr] =  plotColors();


% Mean AUC
figure;
if Nfolds==1
  plot(mean_auc_models, 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  boxplot(mean_auc_models);
end
set(gca, 'xtick', 1:Nmethods)
set(gca, 'xticklabel',  methodNames)
title(sprintf('AUC averaged over classes'))

% Mean EER
figure;
if Nfolds==1
  plot(mean_eer_models, 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  boxplot(mean_eer_models)
end
set(gca, 'xtick', 1:Nmethods)
set(gca, 'xticklabel', methodNames)
title(sprintf('EER averaged over classes'))



% NLL on labels
figure;
if Nfolds==1
  plot(-loglik_models, 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  boxplot(-loglik_models)
end
set(gca, 'xtick', 1:Nmethods)
set(gca, 'xticklabel', methodNames)
title(sprintf('negloglik'))

%% Plot some ROC curves for some classes on a single fold
for c=1:3
  absent(c) = all(test.presence(:,c)==0);
  if absent(c),
    error(sprintf('%s is absent in this test fold', objectnames{c}))
  end
  figure; hold on; h = []; legendstr = {};
  for m=1:Nmethods
    [AUC, falseAlarmRate, detectionRate, EER, cutoff, tprAtThresh, fprAtThresh, thresh] = ...
      rocPMTK(presence_model(:,c,m), test.presence(:,c), fprThresh);
    h(m) = plotROC(falseAlarmRate, detectionRate, colors(m+1), EER, tprAtThresh, fprAtThresh);
    legendstr{m} = sprintf('%s (AUC %5.3f, EER %5.3f)', methodNames{m}, AUC, EER);
  end
  legend(h, legendstr, 'location', 'southwest')
  title(objectnames{c})
  fname = fullfile(figFolder, sprintf('roc-%s.png', objectnames{c}));
  print(gcf, '-dpng', fname);
end

%% Visualize predictions plotted on top of some images

dataDir = '/home/kpmurphy/LocalDisk/SUN09/';
HOMEIMAGES = fullfile(dataDir, 'Images');
%HOMEANNOTATIONS = fullfile(dataDir, 'Annotations');
sun_folder = 'static_sun09_database';

%{
 Contents of groundTruth
categories: [1x1 struct]
               Dtest: [1x4317 struct]
    DtrainingObjects: [1x28472 struct]
       Doutofcontext: [1x42 struct]
           Dtraining: [1x4367 struct]
%}
fname = fullfile(dataDir, 'dataset', 'sun09_groundTruth');
load(fname, 'Dtest')


% presence_model(n,c,m), test.presence(n,c), cutoff_models(c,m)
visPredictions(test.presence,  presence_model, objectnames, methodNames, ...
  test.filenames, cutoff_fpr, Dtest);









%% plot improvement over baseline on a single fold for each method as separate figs 
%  auc_models = nan(Nobjects, Nmethods);
% We assume that method 1 is the independent model
for m=2:Nmethods
  figure;
  [delta, perm] = sort(auc_models(:,m) - auc_models(:,1), 'descend');
  bar(delta)
  xlabel('category')
  ylabel(sprintf('improvement in AUC over baseline'))
  fname = fullfile(figFolder, sprintf('roc-delta-%s.png', methodNames{m}));
  print(gcf, '-dpng', fname);
end



