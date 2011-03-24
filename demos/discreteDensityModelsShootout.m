% Compare various joint density models on categorical (mostly binary) datsets
% We visualize the learned structuers and evaluated loglik on test set


%% Data
% labels is N*D, where labels(n,d) in {1..Nstates(d)}

dataName = 'temperature';
switch dataName
  case 'newsgroups'
  loadData('20news_w100');
  % documents, wordlist, newsgroups, groupnames
  labels = double(full(documents))'+1; % 16,642 documents by 100 words  (sparse logical  matrix)
  nodeNames = wordlist;
  Nstates = 2*ones(1,numel(nodeNames));

  case 'SUN09'
  loadData('sceneContextSUN09', 'ismatfile', false)
  load('SUN09data')
  % 8684 images x 111 tags
  % we merge the training and test data into one big blob
  % so that we can use CV
  labels = [data.train.presence; data.test.presence]+1;
  nodeNames = data.names;
  clear data
  Nstates = 2*ones(1,numel(nodeNames));

 case 'voting'
   load('house-votes-84')
   Y = data.X; % 435 x 17
   % omit columns 3,11,12, which are not very correlated
   %ndx = [1:2 4:10 13:17];
   ndx = 1:17;
   Y = Y(:,ndx);
   % omit rows with any Nan - this leaves 232 rows
   idx = find(~sum(isnan(Y),2));
   labels = Y(idx, :);
   nodeNames = data.names(ndx);
   Nstates = 2*ones(1,numel(nodeNames));
   
  case 'temperature'
    load deshpande_intel % X is 18,054 x 54, 0,1,2,3
    %labels = (X>=2)+1; % binarize
    labels = X+1;
    D = size(labels,2);
    nodeNames = cellfun(@(d) sprintf('n%d', d), num2cell(1:D), 'uniformoutput', false);
    Nstates = nunique(labels(:))*ones(1,numel(nodeNames));
end 
isbinary =  all(Nstates==2)

% Where to store plots (set figFolder = [] to turn of printing)
if isunix
  figFolder = '/home/kpmurphy/Dropbox/figures/googleJointModelsTalk';
end
if ismac
  figFolder = '/Users/kpmurphy/Dropbox/figures/googleJointModelsTalk';
end

%% Models/ methods

methods = [];
m = 0;

  
m = m + 1;
methods(m).modelname = 'indep';
methods(m).fitFn = @(labels) discreteFit(labels);
methods(m).logprobFn = @(model, labels) discreteLogprob(model, labels);
methods(m).predictMissingFn = @(model, labels) discretePredictMissing(model, labels);



%%%%%%%%%%%%%% Tree

%{
m = m + 1;
methods(m).modelname = 'tree';
methods(m).fitFn = @(labels) treegmFit(labels);
methods(m).logprobFn = @(model, labels) treegmLogprob(model, labels);
%}


%%%%%%%%%%%%%% DGM
%{
% For debugging - an empty dag should be the same as the independent model
m = m + 1;
methods(m).modelname = 'dgm-empty';
methods(m).fitFn = @(labels) dgmFitStruct(labels, 'nodeNames', nodeNames, 'emptyGraph', true);
methods(m).logprobFn = @(model, labels) dgmLogprob(model, 'obs', labels);
%}



%{
% For debugging - if we initialize search at a tree and perform 0
% iterations of DAG search, we should get the same resutls as treegmFit
m = m + 1;
methods(m).modelname = 'dgm-tree';
methods(m).fitFn = @(labels) dgmFitStruct(labels, 'nodeNames', nodeNames, 'maxFamEvals', 500, ...
  'figFolder', figFolder, 'nrestarts', 0, 'maxIter', 0, 'initMethod', 'tree');
methods(m).logprobFn = @(model, labels) dgmLogprob(model, 'obs', labels);
%}

%{
% Using no edge restrictions is very slow!
m = m + 1;
methods(m).modelname = 'dgm-init-tree-restrict-none';
methods(m).fitFn = @(labels) dgmFitStruct(labels, 'nodeNames', nodeNames, 'maxFamEvals', 500, ...
  'figFolder', figFolder, 'nrestarts', 2, 'initMethod', 'tree', 'edgeRestrict', 'none');
methods(m).logprobFn = @(model, labels) dgmLogprob(model, 'obs', labels);
%}


%{
m = m + 1;
methods(m).modelname = 'dgm-init-tree';
methods(m).fitFn = @(labels) dgmFitStruct(labels, 'nodeNames', nodeNames, 'maxFamEvals', 1000, ...
  'figFolder', figFolder, 'nrestarts', 0, 'initMethod', 'tree', 'edgeRestrict', 'MI');
methods(m).logprobFn = @(model, labels) dgmLogprob(model, 'obs', labels);
%}

%{
m = m + 1;
methods(m).modelname = 'dgm-init-empty';
methods(m).fitFn = @(labels) dgmFitStruct(labels, 'nodeNames', nodeNames, 'maxFamEvals', 1000, ...
  'figFolder', figFolder, 'nrestarts', 2, 'initMethod', 'empty', 'edgeRestrict', 'MI');
methods(m).logprobFn = @(model, labels) dgmLogprob(model, 'obs', labels);

%}

%{

m = m + 1;
methods(m).modelname = 'dgm-init-tree-restrict-L1';
methods(m).fitFn = @(labels) dgmFitStruct(labels, 'nodeNames', nodeNames, 'maxFamEvals', 1000, ...
  'figFolder', figFolder, 'nrestarts', 2, 'initMethod', 'tree', 'edgeRestrict', 'L1');
methods(m).logprobFn = @(model, labels) dgmLogprob(model, 'obs', labels);

%}


%%%%%%%%%%%%%% MRF

%{
m = m + 1;
lambdaNode = 0.1; lambdaEdge = 50;
methods(m).modelname = 'mrf-L1';
methods(m).fitFn = @(labels) mrf2FitStruct(labels, ...
  'lambdaNode', lambdaNode, 'lambdaEdge', lambdaEdge, 'nstates', 2*ones(1,numel(nodeNames)), ...
  'nodeNames', nodeNames);
methods(m).logprobFn = @(model, labels) mrf2Logprob(model, labels);
%[logZBF, nodeBelBF] = crf2InferNodes(model, X(testNdx,:,:), [], 'infMethod', 'bruteforce');
%}


%%%%%%%%%%%%%% Mix

%{
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
%}


%%%%%%%%%%%%%% Categorical FA


%{
%[mu, Sigma, loglikCases, loglikAvg] = catFAinferLatent(model,discreteData, ctsData)
%[predD, predC] = catFApredictMissing(model, testData)
m = m + 1;
methods(m).modelname = 'catFA-2';
methods(m).fitFn = @(labels) catFAfit(labels, [],  2, 'maxIter', 50, 'verbose', false);
methods(m).logprobFn = @(model, labels) argout(3, @catFAinferLatent, model, labels, []);
methods(m).predictMissingFn = @(model, labels) catFApredictMissing(model, labels, []);

m = m + 1;
methods(m).modelname = 'catFA-5';
methods(m).fitFn = @(labels) catFAfit(labels, [],  5, 'nlevels', Nstates, 'maxIter', 50, 'verbose', false);
methods(m).logprobFn = @(model, labels) argout(3, @catFAinferLatent, model, labels, []);
methods(m).predictMissingFn = @(model, labels) catFApredictMissing(model, labels, []);
%}



m = m + 1;
methods(m).modelname = 'catFA-80';
methods(m).fitFn = @(labels) catFAfit(labels, [],  80,  'nlevels', Nstates, 'maxIter', 200, 'verbose', true);
methods(m).logprobFn = @(model, labels) argout(3, @catFAinferLatent, model, labels, []);
methods(m).predictMissingFn = @(model, labels) catFApredictMissing(model, labels, []);


m = m + 1;
methods(m).modelname = 'catFA-150';
methods(m).fitFn = @(labels) catFAfit(labels, [],  150,  'nlevels', Nstates, 'maxIter', 200, 'verbose', true);
methods(m).logprobFn = @(model, labels) argout(3, @catFAinferLatent, model, labels, []);
methods(m).predictMissingFn = @(model, labels) catFApredictMissing(model, labels, []);


m = m + 1;
methods(m).modelname = 'catFA-300';
methods(m).fitFn = @(labels) catFAfit(labels, [],  300,  'nlevels', Nstates, 'maxIter', 200, 'verbose', true);
methods(m).logprobFn = @(model, labels) argout(3, @catFAinferLatent, model, labels, []);
methods(m).predictMissingFn = @(model, labels) catFApredictMissing(model, labels, []);



Nmethods = numel(methods);


%% CV
setSeed(0);
N = size(labels, 1)
% pcTrain and pcTest do not need to sum to one
% This way, you can use a fraction of the overall data
pcTrain = 0.25; pcTest = 0.25;
Nfolds = 1;
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
pcMissing =  0.25; 

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

[styles, colors, symbols, plotstr] =  plotColors();

%{
% NLL - exclude catFA, which cannot compute valid loglik
figure;
ndx = 1:2
if Nfolds==1
  plot(-loglik_models(ndx), 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  boxplot(-loglik_models(:, ndx))
end
set(gca, 'xtick', 1:numel(ndx))
set(gca, 'xticklabel', methodNames(ndx))
%xticklabelRot(methodNames(ndx), -45);
title(sprintf('negloglik on %s', dataName))
fname = fullfile(figFolder, sprintf('negloglik-%s.png', dataName));
print(gcf, '-dpng', fname);
%}

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
fname = fullfile(figFolder, sprintf('imputation-%s.png', dataName));
print(gcf, '-dpng', fname);


%% Visualize models themselves

break

m = strfindCell('tree', methodNames);
if ~isempty(m)
  tree = models{m};
  % The tree is undirected, but for some reason, gviz makes directed graphs
  % more readable than undirected graphs
  fname = fullfile(figFolder, sprintf('tree-%s', dataName))
  graphviz(tree.edge_weights, 'labels', nodeNames, 'directed', 1, 'filename', fname);
end

m = strfindCell('dgm', methodNames);
if ~isempty(m)
  dgm = models{m};
  % The node names get permuted so we must use dgm.nodeNames
  fname = fullfile(figFolder, sprintf('dgm-%s', dataName))
  graphviz(dgm.G, 'labels', dgm.nodeNames, 'directed', 1, 'filename', fname);
end

m = strfindCell('mrf-L1', methodNames);
if ~isempty(m)
  mrf = models{m};
  fname = fullfile(figFolder, sprintf('mrf-L1-%s', dataName))
  graphviz(mrf.G, 'labels', nodeNames, 'directed', 0, 'filename', fname);
end


m = strfindCell('mix10', methodNames);
if ~isempty(m)
  mix = models{m};
  K = mix.nmix;
  [nr,nc] = nsubplots(K);
  %figure;
  for k=1:K
    T = squeeze(mix.cpd.T(k,2,:));
    ndx = topAboveThresh(T, 5, 0.1);
    memberNames = sprintf('%s,', nodeNames{ndx});
    disp(memberNames)
    %subplot(nr, nc, k)
    %bar(T);
    %title(sprintf('%5.3f', mix.mixWeight(k)))
  end
end


%{
% Fit a depnet to the labels
%model = depnetFit(labels, 'nodeNames', nodeNames, 'method', 'ARD');
model = depnetFit(labels, 'nodeNames', nodeNames, 'method', 'MI');
fname = fullfile(figFolder, sprintf('depnet-MI-%s', dataName))
graphviz(model.G, 'labels', nodeNames, 'directed', 1, 'filename', fname);
%}


