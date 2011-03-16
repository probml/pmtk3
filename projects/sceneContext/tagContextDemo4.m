
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
methods(m).fitFn = @(labels, features) dgmFit(labels);
methods(m).infFn = @(model, features, softev) argout(2, @treegmInferNodes, model, [], softev);
methods(m).logprobFn = @(model, labels) treegmLogprob(model, labels);

m = m + 1;
methods(m).modelname = 'mix1';
methods(m).obstype = 'detector';
methods(m).fitFn = @(labels, features) noisyMixModelFit(labels, [], 1);
methods(m).infFn = @(model, features, softev) argout(2, @noisyMixModelInferNodes, model, [], softev);
methods(m).logprobFn = @(model, labels) mixModelLogprob(model, labels);


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
Nfolds = 3;
if Nfolds == 1
  % use original train/ test split
  trainfolds{1} = 1:Ntrain;
  testfolds{1} = (Ntrain+1):(Ntrain+Ntest);
else
  [trainfolds, testfolds] = Kfold(N, Nfolds);
end
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

  
  % Train up models
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
    ll_model(:, m) = methods{m}.logprobFn(models{m}, labels);
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
      
      switch method(m).obstype
        case 'detector'
          bel = infMethods{m}(models{m}, [], test.detect_maxprob(n, :));
        case 'gauss'
          bel = infMethods{m}(models{m}, [], softevBatchGauss(:, :, n));
      end
      
      probPresent = bel(2,:);
      presence_model(n,:,m) = probPresent;
      
         
      % visualize some predictions -  needs database of images
    if 0 % fold==1 && (n <= 3)
      srcfolder = '';
      destfolder = '';
      img = imread(fullfile(HOMEIMAGES, srcfolder{frame}, test.filename{frame}));
      figure(1); clf; image(img)
      trueObjects = sprintf('%s,', objectnames{find(test.presence(frame,:))});
      title(trueObjects)
      fname = fullfile(destfolder, sprintf('testimg%d-truth.png', n));
      print(gcf, '-dpng', fname);
      
      figure(2); clf; image(img)
      predObjects = sprintf('%s,', objectsnames{find(probPresent > 0.5));
      title(predObjects)
      fname = fullfile(destfolder, sprintf('testimg%d-%s.png', n, methodNames{m}));
      print(gcf, '-dpng', fname);
    end
      
    end % for n
  end % for m
  
  %% Performance evaluation
  evalPerf =   @(confidence, truth) rocPMTK(confidence, truth);
  perfStr = 'aROC';
  
  % If the object is absent in a given fold, we may get NaN for
  % the performance. We want to exclude these from the evaluation.
  score_indep = nan(1, Nobjects);
  score_models = nan(Nobjects, Nmethods);
  absent = zeros(1, Nobjects);
  for c=1:Nobjects
    absent(c) = all(test.presence(:,c)==0);
    if absent(c), continue; end
    [score_indep(c)] = evalPerf(presence_indep(:,c), test.presence(:,c));
    for m=1:Nmethods
      score_models(c,m) = evalPerf(presence_model(:,c,m), test.presence(:,c));
    end
  end
  if ~isempty(absent)
    fprintf('warning: in fold %d of %d, %s are absent from test\n', ...
      fold, Nfolds, sprintf('%s,', objectnames{find(absent)}));
  
  mean_perf_indep(fold) = mean(score_indep(~absent));
  for m=1:Nmethods
    mean_perf_models(fold,m) = mean(score_models(~absent,m));
  end
  
  
end % fold



%% Plotting

[styles, colors, symbols, plotstr] =  plotColors();


%{
    % plot improvement over baseline for each method as separate figs
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
    end
  end
%}

% Plot some ROC curves for some classes on a single fold
if 1
  for c=1:3
    absent(c) = all(test.presence(:,c)==0);
    if absent(c), 
      error(sprintf('%s is absent in this test fold', objectnames{c}))
    end
    figure;
    [aROC, falseAlarmRate, detectionRate] = figROC(presence_indep(:,c), test.presence(:,c), colors(1));
    for m=1:Nmethods
      [aROC, falseAlarmRate, detectionRate] = figROC(presence_model(:,c,m), test.presence(:,c), colors(m+1));
    end
    legendstr = {'indep', methodNames{:}};
    legend(legendstr)
    title(objectnames{c})
  end
end


% Mean AUC
figure;
if Nfolds==1
  %bar([mean_perf_indep mean_perf_models])
  plot([mean_perf_indep mean_perf_models], 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  perf = [mean_perf_indep(:)   mean_perf_models]; % folds * methods
  boxplot(perf)
end
legendstr = {'indep', methodNames{:}};
set(gca, 'xtick', 1:numel(legendstr))
set(gca, 'xticklabel', legendstr)
title(sprintf('mean %s', perfStr))


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

