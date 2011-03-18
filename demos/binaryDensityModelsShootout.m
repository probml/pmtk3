% Compare various joint density models on binary datsets
% We visualize the learned structuers and evaluated loglik on test set


%% Data
setSeed(0);
if 1
  loadData('20news_w100');
  % documents, wordlist, newsgroups, groupnames
   tags = double(documents)'; % 16,642 documents by 100 words  (sparse logical  matrix)
  nodeNames = wordist;
  dataName = 'newsgroups';
else
  loadData('sceneContextSUN09', 'ismatfile', false)
  load('SUN09data')
  % 8684 images x 111 tags
  % we merge the training and test data into one big blob
  % so that we can use CV
  tags = [data.train.presence; data.test.presence];
  nodeNames = data.names;
  clear data
  dataName = 'SUN09';
end

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


m = m + 1;
methods(m).modelname = 'tree';
methods(m).fitFn = @(labels) treegmFit(labels);
methods(m).logprobFn = @(model, labels) treegmLogprob(model, labels);


m = m + 1;
methods(m).modelname = 'mix5';
methods(m).fitFn = @(labels) mixModelFit(labels, 5, 'discrete');
methods(m).logprobFn = @(model, labels) mixModelLogprob(model, labels);

%{
m = m + 1;
methods(m).modelname = 'dag-empty';
methods(m).fitFn = @(labels) dgmFit(labels, 'nodeNames', nodeNames, 'emptyGraph', true);
methods(m).logprobFn = @(model, labels) dgmLogprob(model, 'obs', labels);
%}

Nmethods = numel(methods);


%% CV

setSeed(0);
N = size(tags,1);
Nfolds = 1;
if Nfolds == 1
  N2 = floor(N/2);
  trainfolds{1}  = 1:N2;
  testfolds{1} = (N2+1):N;
else
  [trainfolds, testfolds] = Kfold(N, Nfolds);
end

loglik_models = zeros(Nfolds, Nmethods);
 

for fold=1:Nfolds
  fprintf('fold %d of %d\n', fold, Nfolds);
 
  % we convert the labels from {0,1} to {1,2}
  train.labels = tags(trainfolds{fold}, :)+1;
  test.labels = tags(testfolds{fold}, :)+1;
 
  
  models = cell(1, Nmethods);
  for m=1:Nmethods
    methodNames{m} = sprintf('%s', methods(m).modelname); %#ok
    fprintf('fitting %s\n', methodNames{m});
    models{m} = methods(m).fitFn(train.labels);
  end
  
  Ntest = size(test.labels, 1);
  ll = zeros(Ntest, Nmethods);
  for m=1:Nmethods
    fprintf('evaluating %s\n', methodNames{m});
    ll(:, m) = methods(m).logprobFn(models{m}, test.labels);
  end
  loglik_models(fold, :) = sum(ll, 1)/Ntest;
  
end % fold



%% Plot performance

[styles, colors, symbols, plotstr] =  plotColors();


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

%% Visualize models themselves


m = find(cellfun(@(s) strcmpi(s, 'tree'), methodNames));
if ~isempty(m)
  tree = models(m);
  % The tree is undirected, but for some reason, gviz makes directed graphs
  % more readable than undirected graphs
  fname = fullfile(figFolder, sprintf('tree-%s', dataName));
  graphviz(tree.edge_weights, 'labels', nodeNnames, 'directed', 1, 'filename', fname);
end

