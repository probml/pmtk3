 

%% Data
loadData('sceneContextSUN09', 'ismatfile', false)
load('SUN09data')
objectnames  = data.names;

if isunix
  figFolder = '/home/kpmurphy/Dropbox/figures/sceneContext';
end
if ismac
  figFolder = '/Users/kpmurphy/Dropbox/figures/sceneContext';
end

%% Models/ methods

methods = [];
m = 0;

%{
m = m + 1;
methods(m).modelname = 'det';
methods(m).obstype = 'detector';
methods(m).fitFn = @(labels, features) discreteFit(labels);
methods(m).infFn = @(model, features, softev) softev; % just spit back detector
methods(m).logprobFn = @(model, labels) discreteLogprob(model, labels);

m = m + 1;
methods(m).modelname = 'det';
methods(m).obstype = 'gauss';
methods(m).fitFn = @(labels, features) discreteFit(labels);
methods(m).infFn = @(model, features, softev) softev; % just spit back detector
methods(m).logprobFn = @(model, labels) discreteLogprob(model, labels);

m = m + 1;
methods(m).modelname = 'det';
methods(m).obstype = 'gauss-hack';
methods(m).fitFn = @(labels, features) discreteFit(labels);
methods(m).infFn = @(model, features, softev) softev; % just spit back detector
methods(m).logprobFn = @(model, labels) discreteLogprob(model, labels);
%}


%[nodeBel] = discreteInferNodes(model, softev);
m = m + 1;
methods(m).modelname = 'indep';
methods(m).obstype = 'gauss';
methods(m).fitFn = @(labels, features) discreteFit(labels);
methods(m).infFn = @(model, features, softev) discreteInferNodes(model, softev);
methods(m).logprobFn = @(model, labels) discreteLogprob(model, labels);



%[logZ, nodeBel] = treegmInferNodes(treeModel, localFeatures, softev);
m = m + 1;
methods(m).modelname = 'tree';
methods(m).obstype = 'gauss';
methods(m).fitFn = @(labels, features) treegmFit(labels);
methods(m).infFn = @(model, features, softev) argout(2, @treegmInferNodes, model, [], softev);
methods(m).logprobFn = @(model, labels) treegmLogprob(model, labels);


%{
%[pZ, pX] = noisyMixModelInferNodes(mixModel{ki}, localFeatures, softev);
m = m + 1;
methods(m).modelname = 'mix20';
methods(m).obstype = 'gauss';
methods(m).fitFn = @(labels, features) noisyMixModelFit(labels, [], 10);
methods(m).infFn = @(model, features, softev) argout(2, @noisyMixModelInferNodes, model, [], softev);
methods(m).logprobFn = @(model, labels) mixModelLogprob(model.mixmodel, labels);
%}


%[pZ, pX] = noisyMixModelInferNodes(mixModel{ki}, localFeatures, softev);
m = m + 1;
methods(m).modelname = 'mix40';
methods(m).obstype = 'gauss';
methods(m).fitFn = @(labels, features) noisyMixModelFit(labels, [], 40);
methods(m).infFn = @(model, features, softev) argout(2, @noisyMixModelInferNodes, model, [], softev);
methods(m).logprobFn = @(model, labels) mixModelLogprob(model.mixmodel, labels);





%{
%[nodeBelCell, logZ, nodeBelArray] = dgmInferNodes(dgm, 'softev', softev)
%logZ = dgmLogprob(dgm, 'clamped', Y)
m = m + 1;
methods(m).modelname = 'dag-empty';
methods(m).obstype = 'gauss';
methods(m).fitFn = @(labels, features) dgmFit(labels, 'nodeNames', objectnames, 'emptyGraph', true);
methods(m).infFn = @(model, features, softev) argout(3, @dgmInferNodes, model, 'softev', softev);
methods(m).logprobFn = @(model, labels) dgmLogprob(model, 'obs', labels);


%[nodeBelCell, logZ, nodeBelArray] = dgmInferNodes(dgm, 'softev', softev)
%logZ = dgmLogprob(dgm, 'clamped', Y)
m = m + 1;
methods(m).modelname = 'dag';
methods(m).obstype = 'gauss';
methods(m).fitFn = @(labels, features) dgmFit(labels, 'nodeNames', objectnames);
methods(m).infFn = @(model, features, softev) argout(3, @dgmInferNodes, model, 'softev', softev);
methods(m).logprobFn = @(model, labels) dgmLogprob(model, 'obs', labels);
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
dataNdx = 1:N;
assert(N==Ntrain+Ntest);
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
    %methodNames{m} = sprintf('%s-%s', methods(m).modelname, methods(m).obstype); %#ok
     methodNames{m} = sprintf('%s', methods(m).modelname); %#ok
    fprintf('fitting %s\n', methodNames{m});
    models{m} = methods(m).fitFn(labels, scores);
  end
  
   %% Probability of labels
  ll = zeros(Ntest, Nmethods);
  labels = test.presence+1; % 1,2
  for m=1:Nmethods
    ll(:, m) = methods(m).logprobFn(models{m}, labels);
  end
  loglik_models(fold, :) = sum(ll, 1)/Ntest

  
  %% Inference
  presence_model = zeros(Ntest, Nobjects, Nmethods);  
  features = test.detect_maxprob; %Ncases*Nnodes*Ndims
  % as a speedup, we compute soft evidence from features in batch form
  softevBatchGauss = obsModelEval(obsmodelGauss, features);
  %[quantizedScores, discretizeParams] = discretizePMTK(scores, 10);
  
  for m=1:Nmethods
    fprintf('running inference for method %s\n', methodNames{m});
    
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
          bel = methods(m).infFn(models{m}, [], softev);
        case 'gauss-hack'
          softev = softevBatchGauss(:, :, n);
          % hack to prevent too many false positives: 
          % if detector doesn't fire, don't hallucinate objects
          % by setting soft evidence for the on state to be hard 0
          ndx = find(test.detect_maxprob(n,:) < 1e-5);
          softev(2, ndx) = 0;
          bel = methods(m).infFn(models{m}, [], softev);
      end
      probPresent = bel(2,:);
      assert(~any(isnan(probPresent)))
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
ndx = 1:Nmethods;
figure;
if Nfolds==1
  plot(mean_auc_models, 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  boxplot(mean_auc_models(:, ndx));
end
set(gca, 'xtick', 1:numel(ndx))
set(gca, 'xticklabel',  methodNames(ndx))
title(sprintf('AUC averaged over classes'))
fname = fullfile(figFolder, sprintf('boxplot-auc.png'));
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
set(gca, 'xticklabel', methodNames(ndx))
title(sprintf('EER averaged over classes'))
fname = fullfile(figFolder, sprintf('boxplot-eer.png'));
print(gcf, '-dpng', fname);
  

    
%% Plot some ROC curves for some classes on a single fold
ndx = 1:Nmethods;
for c=1:4
  absent(c) = all(test.presence(:,c)==0);
  if absent(c),
    error(sprintf('%s is absent in this test fold', objectnames{c}))
  end
  figure; hold on; h = []; legendstr = {};
  for mm=1:numel(ndx)
    m = ndx(mm);
    [AUC, falseAlarmRate, detectionRate, EER, cutoff, tprAtThresh, fprAtThresh, thresh] = ...
      rocPMTK(presence_model(:,c,m), test.presence(:,c), fprThresh);
    %h(m) = plotROC(falseAlarmRate, detectionRate, colors(mm), EER, tprAtThresh, fprAtThresh);
    h(mm) = plotROC(falseAlarmRate, detectionRate, colors(mm));
    legendstr{mm} = sprintf('%s (AUC %5.3f, EER %5.3f)', methodNames{m}, AUC, EER);
  end
  legend(h, legendstr, 'location', 'southeast')
  title(objectnames{c})
  fname = fullfile(figFolder, sprintf('roc-%s.png', objectnames{c}));
  print(gcf, '-dpng', fname);
end


%% plot improvement over baseline on a single fold for each method as separate figs 
%  auc_models = nan(Nobjects, Nmethods);
% We assume that method 1 is the independent model

for m=2:Nmethods
  figure;
  [delta, perm] = sort(auc_models(:,m) - auc_models(:,1), 'descend');
  bar(delta)
  xlabel('category')
  ylabel(sprintf('improvement in AUC over baseline'))
  title(methodNames{m})
  fname = fullfile(figFolder, sprintf('roc-delta-%s.png', methodNames{m}));
  print(gcf, '-dpng', fname);
end


%% Visualize predictions plotted on top of some images


% presence_model(n,c,m), test.presence(n,c), cutoff_models(c,m)

frames = [1,100,500,1000,2000];
frames = [1:20]

printPredictions(test.presence,  presence_model, objectnames, methodNames, test.filenames, cutoff_fpr, frames);


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
if Nfolds == 1
  DB = Dtest;
else
  load(fname, 'Dtraining')
  DB = [Dtraining Dtest];
  DBtrain = DB(trainfolds{fold});
  DBtest = DB(testfolds{fold});
end

frames = 1

visPredictions(test.presence,  presence_model, objectnames, methodNames, test.filenames, cutoff_fpr, DB, frames);







