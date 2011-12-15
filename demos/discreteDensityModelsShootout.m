%PMTKslow

% Compare various joint density models on categorical (mostly binary) datsets
% We visualize the learned structuers and evaluate loglik and
% imputation error on test sets


%% Data
% labels is N*D, where labels(n,d) in {1..Nstates(d)}



Nfolds = 1;
% pcTrain and pcTest do not need to sum to one
% This way, you can use a fraction of the overall data
pcTrain = 0.1; pcTest = 0.1;
pcMissing =  0.3;

%dataName = 'SUN09';
dataName = 'newsgroups';
%dataName = 'newsgroups1';
%dataName = 'ases4';

switch dataName
  case 'newsgroups'
  loadData('20news_w100');
  % documents, wordlist, newsgroups, groupnames
  labels = double(full(documents))'+1; % 16,642 documents by 100 words  (sparse logical  matrix)
  nodeNames = wordlist;
  Nstates = 2*ones(1,numel(nodeNames));
  
  case 'newsgroups1'
    load(['a3newsgroups.mat']);
    % select class
    classId = 1;%there are 4 classes
    idx = find(newsgroups == classId);
    data.discrete = documents(:,idx)' + 1;
    data.discrete = data.discrete'; %KPM
    data.continuous = [];
    % it is possible that some words are always absent
    % In this case, nClass(d)=1 but we want it to be 2
    %nClass = max(data.discrete,[],2);
    nClass = 2*ones(1, size(data.discrete,1));
    labels = data.discrete'; % N*D
    Nstates = nClass;
    nodeNames = wordlist;
    
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
    
  case 'ases4'
    %a = importdata([dirName 'asesLarge.txt']);
    %Y = a.data;
    %names = a.colheaders;
    load('ases'); % Y is 18253x52 double, names is 1x53 cell
    %  remove rows with any missing values
    idx = find(~sum(isnan(Y),2));
    X = Y(idx,:); % 8735 * 53
    labels = X(:,[3:44]);
    names = names(3:44);
    nClass = max(labels,[],1);
    % currently KPM's code assumes all nodes have the same #values
    % So we extract features with 4 states each
    ndx = find(nClass==4);
    labels = labels(:, ndx); % 8735 * 17
    names = names(ndx);
    nClass = 4*ones(1,numel(names));
    Nstates = nClass;
    nodeNames = names;
    
    case 'ases'
    %a = importdata([dirName 'asesLarge.txt']);
    %Y = a.data;
    %names = a.colheaders;
    load('ases'); % Y is 18253x52 double, names is 1x53 cell
    %  remove rows with any missing values
    idx = find(~sum(isnan(Y),2));
    X = Y(idx,:); % 8735 * 53
    labels = X(:,[3:44]);
    names = names(3:44);
    nClass = max(labels,[],1);
    Nstates = nClass;
    nodeNames = names;
    
end 
isbinary =  all(Nstates==2);
nClass = Nstates;

%{
figure; imagesc(labels); colorbar
title(sprintf('%s, N=%d, D=%d', dataName, size(labels,1), size(labels,2)))
drawnow
%}

% Where to store plots (set figFolder = [] to turn of printing)
if isunix
  figFolder = '/home/kpmurphy/Dropbox/figures/googleJointModelsTalk';
end
if ismac
  figFolder = '/Users/kpmurphy/Dropbox/figures/googleJointModelsTalk';
end
figFolder = []; % for public use, turn off figure saving

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
methods(m).predictMissingFn = @(model, labels) treegmPredictMissing(model, labels);
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
Ks = [1,5,20,40];
for kk=1:numel(Ks)
  K = Ks(kk);
  m = m + 1;
  alpha = 1.1;
  %methods(m).modelname = sprintf('mixK%d,a%2.1f', K, alpha);
  methods(m).modelname = sprintf('mix%d', K);
  methods(m).fitFn = @(labels) mixDiscreteFit(labels, K, 'maxIter', 30, ...
    'verbose', false, 'alpha', 1.1);
  methods(m).logprobFn = @(model, labels) mixDiscreteLogprob(model, labels);
  methods(m).predictMissingFn = @(model, labels) mixDiscretePredictMissing(model, labels);
end 
%}

%%%%%%%%%%%%%% Categorical FA


%{
Ks = [1,5,20,40];
for kk=1:numel(Ks)
  K = Ks(kk);
  m = m + 1;
  methods(m).modelname = sprintf('dFA-%d', K);
  methods(m).fitFn = @(labels) catFAfit(labels, [],  K,  'nClass', Nstates, ...
    'maxIter', 15, 'verbose', true);
  methods(m).logprobFn = @(model, labels) nan(size(labels,1),1);
  methods(m).predictMissingFn = @(model, labels) catFApredictMissing(model, labels, []);
end
%}

%%%%%%%%%%%%%% binary FA

%Ks = [150,200,250,300];
Ks = [1,20,50,100,150];
for kk=1:numel(Ks)
  K = Ks(kk);
  m = m + 1;
  methods(m).modelname = sprintf('bFA-%d', K);
  methods(m).fitFn = @(labels) binaryFAfit(labels,  K,   ...
    'maxIter', 15, 'verbose', true, 'computeLoglik', false);
  methods(m).logprobFn = @(model, labels) nan(size(labels,1),1);
  methods(m).predictMissingFn = @(model, labels) argout(2, @binaryFApredictMissing, model, labels);
end


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
  %fprintf('train=1:%d, test = %d:%d\n', stop, stop+1, stop+stop2);
  %trainfolds{1} = 1:N;
  %testfolds{1} = 1:N;
else
  randomize = true;
  [trainfolds, testfolds] = Kfold(N, Nfolds, randomize);
end


loglik_models = zeros(Nfolds, Nmethods);
imputation_err_entropy = zeros(Nfolds, Nmethods);
imputation_err_binary = zeros(Nfolds, Nmethods);


for fold=1:Nfolds

  train.labels = labels(trainfolds{fold}, :);
  test.labels = labels(testfolds{fold}, :);
  [Ntrain, Nnodes] = size(train.labels);
  [Ntest, Nnodes2] = size(test.labels);
  
  fprintf('fold %d of %d, Ntrain %d, Ntest %d\n', ...
    fold, Nfolds, Ntrain, Ntest);
 
  
  missingMask = rand(Ntest, Nnodes) < pcMissing;
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
  imputationErrBinary = zeros(1,Nmethods);
  for m=1:Nmethods
    fprintf('evaluating %s\n', methodNames{m});
    ll(m) = sum(methods(m).logprobFn(models{m}, test.labels))/Ntest;
    
    if isfield(methods(m), 'predictMissingFn')
      pred = methods(m).predictMissingFn(models{m}, test.labelsMasked);
      % for binary data - MSE is fine
      probOn = pred(:,:,2);  
      testBinary = (test.labels==2);
      imputationErrBinary(m) = sum(sum((probOn-testBinary).^2))/Ntest; 
      

      %{
      % for K-ary data - MSE not so meaningful
      % so we use cross entropy
      [~,truth3d] = dummyEncoding(test.labels, Nstates);
      %imputationErr(m) = sum(sum(sum((truth3d-pred).^2)))/Ntest;
      %logprob = sum(sum(log(sum(truth3d .* pred, 3))))/Ntest;
      logprob = reshape(log2(pred(find(truth3d)) + eps), [Ntest Nnodes]);
      logprobAvg = mean(logprob(:));
      logprobAvg2 = mean(logprob(missingMask(:)));
      
      % Just assess performance on the missing entries
      % This does not affect the relative performance of methods
      %logprob = log(sum(truth3d .* pred, 3)); % N*D
      %logprobAvg = sum(sum(logprob(missingMask)))/sum(missingMask(:));
      
      
      %logprob = sum(truth3d(missingMask3d) .* log2(pred(missingMask3d)+eps), 3); % logprob(n,d)
      %logprobAvg = sum(sum(logprob))/(Ntest*length(nClass))
      %}
      
      % Emt's evaluation code
      nClass = Nstates;
      yd = test.labelsMasked';
      ydT = test.labels';
      ydT_oneOfM = encodeDataOneOfM(ydT, nClass, 'M');
      yd_oneOfM = encodeDataOneOfM(yd, nClass, 'M');
      N = size(yd_oneOfM,2);
      miss = isnan(yd_oneOfM);
      % pred is N * D * K
      pred2 = permute(pred, [3 2 1]); % K D N
      pred3 = reshape(pred2, [sum(nClass) Ntest]); % KD * N 
      %yhatD = reshape(pred+eps, [Ntest sum(nClass)])';
      
      
      % if predict [0 0], replace with eps
      M = nClass;
      for d = 1:length(M)
        idx = sum(M(1:d-1))+1:sum(M(1:d));
        p1 = pred3(idx,:);
        if ~isempty(find(sum(p1,2) == 0))
          p1 = p1 + eps;
          p1 = bsxfun(@times, p1, 1./sum(p1));
        end
        pred3(idx,:) = p1;
      end
      yhatD = pred3;
      entrpyD = -sum(ydT_oneOfM(miss).*log2(yhatD(miss)))/(Ntest*length(nClass));
      %entrpyD = -sum(ydT_oneOfM(miss).*log2(yhatD(miss)))/(sum(miss(:)));    
      
      imputationErr(m) =  entrpyD;
    end
  end
  loglik_models(fold, :) = ll;
  imputation_err_entropy(fold, :) = imputationErr;
  imputation_err_binary(fold, :) = imputationErrBinary;
end % fold

    
    
%{
% Debug - check that tree has correct marginals
% Compute unconditional marginals from tree
mTree = strfindCell('tree', methodNames);
[logZ, nodeBelTree] = treegmInferNodes(models{mTree});


% Compare to marginals from indep model
mIndep = strfindCell('indep', methodNames);
nodeBelIndep = models{mIndep}.T;
assert(approxeq(nodeBelIndep, nodeBelTree))
%}

%{
% Debug - check that independent model is same
% as mixture with 1 component
mMix = strfindCell('mix1', methodNames);
mIndep = strfindCell('indep', methodNames);
predIndep = methods(mIndep).predictMissingFn(models{mIndep}, test.labelsMasked); 
predMix = methods(mMix).predictMissingFn(models{mMix}, test.labelsMasked);
assert(approxeq(predIndep, predMix))
%predTree = methods(mTree).predictMissingFn(models{mTree}, test.labelsMasked);
%}


%% Plot performance

[styles, colors, symbols, plotstr] =  plotColors();



% NLL - for catFA, which cannot compute valid loglik,
% we use NaNs
figure;
ndx = 1:Nmethods;
if Nfolds==1
  plot(-loglik_models(ndx), 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
  -loglik_models
else
  boxplot(-loglik_models(:, ndx))
end
set(gca, 'xtick', 1:numel(ndx))
set(gca, 'xticklabel', methodNames(ndx))
%xticklabelRot(methodNames(ndx), -45);
title(sprintf('NLL on %s, D=%d, Ntr=%d, Nte=%d', ...
  dataName, Nnodes, Ntrain, Ntest))
printPmtkFigure(sprintf('negloglik-%s.png', dataName), 'png', figFolder);


% imputation error
figure;
ndx = 1:Nmethods; 
if Nfolds==1
  plot(imputation_err_entropy(ndx), 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
 imputation_err_entropy
else
  boxplot(imputation_err_entropy(:, ndx))
end
set(gca, 'xtick', 1:numel(ndx))
set(gca, 'xticklabel', methodNames(ndx))
%xticklabelRot(methodNames(ndx), -45);
title(sprintf('imputation error (cross entropy) on %s, %5.3fpc missing, D=%d, Ntr=%d, Nte=%d', ...
  dataName, pcMissing, Nnodes, Ntrain, Ntest))
printPmtkFigure(sprintf('imputation-%s.png', dataName), 'png', figFolder);

% mse error
figure;
ndx = 1:Nmethods; 
if Nfolds==1
  plot(imputation_err_binary(ndx), 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  boxplot(imputation_err_binary(:, ndx))
end
set(gca, 'xtick', 1:numel(ndx))
set(gca, 'xticklabel', methodNames(ndx))
%xticklabelRot(methodNames(ndx), -45);
title(sprintf('imputation error (mse) on %s, %5.3fpc missing, D=%d, Ntr=%d, Nte=%d', ...
  dataName, pcMissing, Nnodes, Ntrain, Ntest))
printPmtkFigure(sprintf('imputation-mse-%s.png', dataName), 'png', figFolder);


%% Visualize models themselves

%{

m = strfindCell('tree', methodNames);
if ~isempty(m)
  tree = models{m};
  % The tree is undirected, but for some reason, gviz makes directed graphs
  % more readable than undirected graphs
  fname = fullfile(figFolder, sprintf('tree-%s', dataName))
  graphviz(tree.edge_weights, 'labels', nodeNames, 'directed', 1, 'filename', fname);
end
%}


%{
m = strfindCell('dgm', methodNames);
if ~isempty(m)
  dgm = models{m};
  % The node names get permuted so we must use dgm.nodeNames
  fname = fullfile(figFolder, sprintf('dgm-%s', dataName))
  graphviz(dgm.G, 'labels', dgm.nodeNames, 'directed', 1, 'filename', fname);
end
%}

%{
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
%}

%{
% Fit a depnet to the labels
%model = depnetFit(labels, 'nodeNames', nodeNames, 'method', 'ARD');
model = depnetFit(labels, 'nodeNames', nodeNames, 'method', 'MI');
fname = fullfile(figFolder, sprintf('depnet-MI-%s', dataName))
graphviz(model.G, 'labels', nodeNames, 'directed', 1, 'filename', fname);
%}


