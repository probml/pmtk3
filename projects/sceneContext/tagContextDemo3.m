
% This is like tagContextDemo except we separate out the observation
% model, p(features|labels), which is shared by different priors p(labels)
% We also do cross validation 

%% Data
loadData('sceneContextSUN09', 'ismatfile', false)
load('SUN09data')




%% Models/ methods
methodNames  = { 'tree' };
%methodNames  = { 'dag', 'mix10', 'mix15', 'tree' };


% We requre that fitting methods have this form
% model = fn(truth(N, D), features(N, D, :))
% where truth(n,d) in {0,1}

%{
fitMethods = {
  @(labels, features) dgmFit(labels)
  };
%}


fitMethods = {
  @(labels, features) treegmFit(labels)
  };


%{
fitMethods = {
  @(labels, features) noisyMixModelFit(labels, [], 1), ...
  @(labels, features) noisyMixModelFit(labels, [], 5), ...
  @(labels, features) noisyMixModelFit(labels, [], 10), ...
  @(labels, features) treegmFit(labels)
  };

%}


%[logZ, nodeBel] = treegmInferNodes(treeModel, localFeatures, softev);
%[pZ, pX] = noisyMixModelInferNodes(mixModel{ki}, localFeatures, softev);


%{
infMethods = {
  @(model, features, softev) argout(2, @noisyMixModelInferNodes, model, [], softev)
  };


infMethods = {
  @(model, features, softev) argout(2, @noisyMixModelInferNodes, model, [], softev), ...
  @(model,  features, softev) argout(2, @noisyMixModelInferNodes, model, [], softev), ...
  @(model, features, softev) argout(2, @noisyMixModelInferNodes, model, [], softev), ...
  @(model, features, softev) argout(2, @treegmInferNodes, model, [], softev)
  };
%}


infMethods = {
  @(model, features, softev) argout(2, @treegmInferNodes, model, [], softev)
  };


%{
logprobMethods = {
  @(model, X) mixModelLogprob(model.mixmodel, X)
  };
  

logprobMethods = {
  @(model, X) mixModelLogprob(model.mixmodel, X), ...
  @(model, X) mixModelLogprob(model.mixmodel, X), ...
  @(model, X) mixModelLogprob(model.mixmodel, X), ...
  @(model, X) treegmLogprob(model, X)
  };

  %}
  
logprobMethods = {
  @(model, X) treegmLogprob(model, X)
  };


%% CV

setSeed(0);
% if you want to use a subset of the data,
% select it here  
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
  obstype = 'gauss';
  [obsmode] = obsModelFit(labels, scores, obstype);
  
  
  
  %% Training p(labels)
  
  Nmethods = numel(methodNames);
  models = cell(1, Nmethods);

  % indep model
  Npresent = sum(train.presence, 1);
  priorProb = Npresent/Ntrain;

  
  % Train up models
  for m=1:Nmethods
    fprintf('fitting %s\n', methodNames{m});
    models{m} = fitMethods{m}(labels, scores);
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
    ll_model(:, m) = logprobMethods{m}(models{m}, labels);
  end
  
  ll = [sum(ll_indep) sum(ll_model,1)];
  loglik(fold, :) = ll;
  
 


  %% Inference
  presence_indep = zeros(Ntest, Nobjects);
  presence_model = zeros(Ntest, Nobjects, Nmethods);
  
  features = test.detect_maxprob; %Ncases*Nnodes*Ndims
  % as a speedup, we compute soft evidence from features in batch form
  %softevBatch = localEvToSoftEvBatch(obsmodel, features);
  softevBatch = obsModelEval(obsmodel, features);
  %[quantizedScores, discretizeParams] = discretizePMTK(scores, 10);
   
  for m=1:Nmethods
    fprintf('running method %s with %s\n', methodNames{m}, obstype);
    
    for n=1:Ntest
      frame = n;
      if (n==1) || (mod(n,500)==0), fprintf('testing image %d of %d\n', n, Ntest); end
      softev = softevBatch(:,:,n); % Nstates * Nnodes * 1
      [presence_indep(n,:)] = features(n, :);
      %[presence_indep(n,:)] = softev(2, :);
      bel = infMethods{m}(models{m}, features(n,:), softev);
      presence_model(n,:,m) = bel(2,:);
      
         
      % visualize predictions - % needs database of images
    if fold==1 && (n <= 3)
      img = imread(fullfile(HOMEIMAGES, test.folder{frame}, test.filename{frame}));
      figure(1); clf; image(img)
      trueObjects = sprintf('%s,', test.names{find(test.presence(frame,:))});
      title(trueObjects)
    end
      
    end
  end
  
  %% Performance evaluation
  
  
  [styles, colors, symbols, plotstr] =  plotColors();
  
  evalFns = {
    @(confidence, truth) argout(1, @rocPMTK, confidence, truth)
    };
  
  %{
evalFns = {
  @(confidence, truth) argout(4, @precisionRecallPMTK, confidence, truth), ...
  @(confidence, truth) argout(1, @rocPMTK, confidence, truth)
  };
    %}
    
    evalNames = {sprintf('aROC+%s', obstype)};
    %evalNames = {'avgPrec', 'aROC'};
    
    evalPerf = evalFns{1};
    perfStr = evalNames{1};
    
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
    end
    %score_indep(isnan(score_indep)) = 0;
    %score_models(isnan(score_models)) = 0;
    
    
    mean_perf_indep(fold) = mean(score_indep(~absent));
    for m=1:Nmethods
      mean_perf_models(fold,m) = mean(score_models(~absent,m));
    end
   
    if 0 %  fold==1
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
  
end % fold


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

    