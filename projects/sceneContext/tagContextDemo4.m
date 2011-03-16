
% This is like tagContextDemo except we separate out the observation
% model, p(features|labels), which is shared by different priors p(labels)
% We also do cross validation 

%% Data
loadData('sceneContextSUN09', 'ismatfile', false)
load('SUN09data')
objectnames  = data.names;



%% Models/ methods

methods = [];
m = 0;

m = m + 1;
methods(m).modelname = 'tree';
methods(m).obstype = 'gauss';
methods(m).fitFn = @(labels, features) treegmFit(labels);
methods(m).infFn = @(model, features, softev) argout(2, @treegmInferNodes, model, [], softev);
methods(m).logprobFn = @(model, labels) treegmLogprob(model, labels);

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


%[logZ, nodeBel] = treegmInferNodes(treeModel, localFeatures, softev);
%[pZ, pX] = noisyMixModelInferNodes(mixModel{ki}, localFeatures, softev);


%% CV

setSeed(0);
[Ntrain Nobjects] = size(data.train.presence);
objectnames = data.names;
Ntest = size(data.test.presence,1);
presence = [data.train.presence; data.test.presence];
detect_maxprob = [data.train.detect_maxprob; data.test.detect_maxprob];
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
mean_auc_indep = zeros(1, Nfolds);
mean_eer_indep = zeros(1, Nfolds);
mean_auc_models = zeros(Nmethods, Nfolds);
mean_eer_models = zeros(Nmethods, Nfolds);
loglik = zeros(Nfolds, Nmethods+1);
  
  
for fold=1:Nfolds
  fprintf('fold %d of %d\n', fold, Nfolds);
  train.presence = presence(trainfolds{fold}, :);
  train.detect_maxprob = detect_maxprob(trainfolds{fold}, :);
  test.presence = presence(testfolds{fold}, :);
  test.detect_maxprob = detect_maxprob(testfolds{fold}, :);
  [Ntrain, Nobjects] = size(train.presence);
  [Ntest, Nobjects2] = size(test.presence);
  
  %% Train  p(scores | labels)
  
  labels = train.presence;
  scores = train.detect_maxprob;
  %[quantizedScores, discretizeParams] = discretizePMTK(scores, 10);
  [obsmodelGauss] = obsModelFit(labels, scores, 'gauss');
  
  
  
  %% Training p(labels)
  
  models = cell(1, Nmethods);
  % indep model
  Npresent = sum(train.presence, 1);
  priorProb = Npresent/Ntrain;
  
  for m=1:Nmethods
    methodNames{m} = sprintf('%s-%s', methods(m).modelname, methods(m).obstype);
    fprintf('fitting %s\n', methodNames{m});
    models{m} = methods(m).fitFn(labels, scores);
  end
  
  
  
  %% Probability of labels
  % See if the models help with p(y(1:T))
  ll_indep = zeros(1, Ntest); %#ok
  ll_model = zeros(Ntest, Nmethods);
  labels = test.presence+1; % 1,2
  
  %logPrior = [log(1-priorProb+eps); log(priorProb+eps)];
  logPrior = [log(1-priorProb); log(priorProb)];
  ll = zeros(Ntest, Nobjects);
  for j=1:Nobjects
    ll(:,j) = logPrior(labels(:, j), j);
  end
  ll_indep = sum(ll,2);
  
  for m=1:Nmethods
    ll_model(:, m) = methods(m).logprobFn(models{m}, labels);
  end
  
  ll = [sum(ll_indep) sum(ll_model,1)];
  loglik(fold, :) = ll;
  
  
  
  %% Inference
  presence_indep = zeros(Ntest, Nobjects);
  presence_model = zeros(Ntest, Nobjects, Nmethods);
  
  features = test.detect_maxprob; %Ncases*Nnodes*Ndims
  % as a speedup, we compute soft evidence from features in batch form
  softevBatchGauss = obsModelEval(obsmodelGauss, features);
  %[quantizedScores, discretizeParams] = discretizePMTK(scores, 10);
  
  for m=1:Nmethods
    fprintf('running method %s\n', methodNames{m});
    
    for n=1:Ntest
      frame = n;
      if (n==1) || (mod(n,500)==0), fprintf('testing image %d of %d\n', n, Ntest); end
      [presence_indep(n,:)] = test.detect_maxprob(n, :);
      
      switch methods(m).obstype
        case 'detector'
          softev = zeros(2, Nobjects);
          softev(1, :) = 1-test.detect_maxprob(n,:);
          softev(2, :) = test.detect_maxprob(n,:);
          bel = methods(m).infFn(models{m}, [], softev);
        case 'gauss'
          bel = methods(m).infFn(models{m}, [], softevBatchGauss(:, :, n));
      end
      
      probPresent = bel(2,:);
      presence_model(n,:,m) = probPresent;
      
    end % for n
  end % for m
  
  %% Performance evaluation
  
  
  % If the object is absent in a given fold, we may get NaN for
  % the performance. We want to exclude these from the evaluation.
  auc_indep = nan(1, Nobjects);
  auc_models = nan(Nobjects, Nmethods);
  % We store the eequal error rate and the cutoff/ threshold that achieves it
  eer_indep = nan(1, Nobjects);
  eer_models = nan(Nobjects, Nmethods);
  cutoff_indep = nan(1, Nobjects);
  cutoff_models = nan(Nobjects, Nmethods);
  absent = zeros(1, Nobjects);
  for c=1:Nobjects
    absent(c) = all(test.presence(:,c)==0);
    if absent(c), continue; end
    %[AUC, cutoff, EER, falseAlarmRate, detectionRate] = rocPMTK(presence_indep(:,c), test.presence(:,c));
    [auc_indep(c), cutoff_indep(c), eer_indep(c)] = rocPMTK(presence_indep(:,c), test.presence(:,c));
    for m=1:Nmethods
      [auc_models(c,m), cutoff_models(c,m), eer_models(c,m)] = ...
        evalPerf(presence_model(:,c,m), test.presence(:,c));
    end
  end
  if ~isempty(absent)
    fprintf('warning: in fold %d of %d, %s are absent from test\n', ...
      fold, Nfolds, sprintf('%s,', objectnames{find(absent)}));
  end
  mean_auc_indep(fold) = mean(auc_indep(~absent));
  mean_eer_indep(fold) = mean(eer_indep(~absent));
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
  plot([mean_auc_indep mean_auc_models], 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  perf = [mean_auc_indep(:)   mean_auc_models]; % folds * methods
  boxplot(perf)
end
legendstr = {'indep', methodNames{:}};
set(gca, 'xtick', 1:numel(legendstr))
set(gca, 'xticklabel', legendstr)
title(sprintf('AUC averaged over classes'))

% Mean EER
figure;
if Nfolds==1
  plot([mean_eer_indep mean_eer_models], 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  perf = [mean_eer_indep(:)   mean_eer_models]; % folds * methods
  boxplot(perf)
end
legendstr = {'indep', methodNames{:}};
set(gca, 'xtick', 1:numel(legendstr))
set(gca, 'xticklabel', legendstr)
title(sprintf('EER averaged over classes'))



% NLL on labels
figure;
if Nfolds==1
  plot(-loglik, 'x', 'markersize', 12, 'linewidth', 2)
  legendstr = {'indep', methodNames{:}};
  set(gca, 'xtick', 1:numel(legendstr))
  set(gca, 'xticklabel', legendstr)
  axis_pct
else
  boxplot(-loglik)
end
legendstr = {'indep', methodNames{:}};
set(gca, 'xtick', 1:numel(legendstr))
set(gca, 'xticklabel', legendstr)
title(sprintf('negloglik'))

%% Visualize predictions plotted on top of some images
Ntest = size(test.presence, 1);

dataDir = '/home/kpmurphy/LocalDisk/SUN09/';
HOMEIMAGES = fullfile(dataDir, 'Images');
%HOMEANNOTATIONS = fullfile(dataDir, 'Annotations');
sun_folder = 'static_sun09_database';
figFolder = '/home/kpmurphy/Dropbox/figures/sceneContext';
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


% presence_model(n,c,m), presence_indep(n,c), test.presence(n,c)
predPresence = cat(3, reshape(presence_indep, [Ntest Nobjects 1]), presence_model);
visPredictions(test.presence,  predPresence, objectnames, {'indep', methodNames{:}}, ...
  test.filenames, Dtest);
 
%{
truePresence = test.presence;
probPresence = predPresence;
methodNamesOrig = methodNames;
methodNames  = {'indep', methodNames{:}};
filenames = test.filenames;
%}
  

%% Plot some ROC curves for some classes on a single fold
if 1
  for c=1:3
    absent(c) = all(test.presence(:,c)==0);
    if absent(c),
      error(sprintf('%s is absent in this test fold', objectnames{c}))
    end
    figure; hold on; h = []; legendstr = {};
    [AUC, cutoff, EER, falseAlarmRate, detectionRate] = rocPMTK(presence_indep(:,c), test.presence(:,c));
    h(1) = plotROC(falseAlarmRate, detectionRate, colors(1));
    legendstr{1} = sprintf('%s (AUC %5.3f, EER %5.3f)', 'indep', AUC, EER);
    for m=1:Nmethods
      [AUC, cutoff, EER, falseAlarmRate, detectionRate] = rocPMTK(presence_model(:,c,m), test.presence(:,c));
      h(m+1) = plotROC(falseAlarmRate, detectionRate, colors(m+1));
      legendstr{m+1} = sprintf('%s (AUC %5.3f, EER %5.3f)', methodNames{m}, AUC, EER);
    end
    legend(h, legendstr, 'location', 'southwest')
    title(objectnames{c})
    fname = fullfile(figFolder, sprintf('roc-%s.png', objectnames{c}));
    print(gcf, '-dpng', fname);
  end
end




%% plot improvement over baseline for each method as separate figs
for m=1:Nmethods
  figure;
  [delta, perm] = sort(score_models(:,m) - score_indep(:), 'descend');
  bar(delta)
  str = sprintf('mean of %s using indep %5.3f, using %s  %5.3f', ...
    perfStr, mean_perf_indep(fold), methodNames{m},  mean_perf_models(fold,m));
  disp(str)
  title(str)
  xlabel('category')
  ylabel(sprintf('improvement in %s over baseline', perfStr))
  fname = fullfile(figFolder, sprintf('roc-delta-%s.png', methodNames{m}));
  print(gcf, '-dpng', fname);
end



