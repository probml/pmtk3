
% This is like tagContextDemo except we separate out the observation
% model, p(features|labels), which is shared by different priors p(labels)

if 0
%% Data
loadData('sceneContextSUN09', 'ismatfile', false)
load('SUN09trainData')
load('SUN09testData')

% For speed, we allow training and testing on a subset
% of the objects and images
[Ntrain, Nobjects] = size(train.presence_truth);
[Ntest, Nobjects2] = size(test.presence_truth); %#ok


objectNdx = 1:Nobjects;
trainNdx = 1:Ntrain;
testNdx = 1:Ntest; % 1:100;

Nobjects = numel(objectNdx);
Ntrain = numel(trainNdx);
Ntest = numel(testNdx);




%% Visualize data
%{
folder = '/home/kpmurphy/Dropbox/figures';
Npresent = sum(train.presence_truth(trainNdx, objectNdx), 1);
priorProb = Npresent/numel(trainNdx);
figure; bar(priorProb);
title('prior probability')
%xticklabelRot(train.names, 45, 8)
xticklabel_rotate(1:Nobjects, 90, train.names, 'fontsize', 8)

% Presence
figure; imagesc(train.presence_truth); colormap(gray)
xlabel('categories')
ylabel('training case')
title('presence or absence')
% Label common objects
common=find(mean(train.presence_truth,1)>0.25);
str = sprintf('%s,', train.names{common});
title(sprintf('%s', str));
xticklabel_rotate(common, 90, train.names(common), 'fontsize', 8);
print(gcf, '-dpng', fullfile(folder, 'SUN09presenceTrain.png'))

% Scores
figure; imagesc(train.maxscores); colorbar
xlabel('categories')
ylabel('training case')
title('max score of detector')
% Label objects whose detectors fire a lot
common=find(mean(train.maxscores,1)>0.6);
str = sprintf('%s,', train.names{common});
title(sprintf('max detector score\n%s', str));
xticklabel_rotate(common, 90, train.names(common), 'fontsize', 8);
print(gcf, '-dpng', fullfile(folder, 'SUN09scoresTrain.png'))
%}




%% Models/ methods
methodNames  = { 'mix1', 'mix5', 'mix10', 'tree' };

% We requre that fitting methods have this form
% model = fn(truth(N, D), features(N, D, :))
% where truth(n,d) in {0,1}

fitMethods = {
  @(labels) noisyMixModelFit(labels, [], 1), ...
  @(labels) noisyMixModelFit(labels, [], 5), ...
  @(labels) noisyMixModelFit(labels, [], 10), ...
  @(labels) treegmFit(labels)
  };
  

%[logZ, nodeBel] = treegmInferNodes(treeModel, localFeatures, softev);
%[pZ, pX] = noisyMixModelInferNodes(mixModel{ki}, localFeatures, softev);

infMethods = {
  @(model, softev) argout(2, @noisyMixModelInferNodes, model, [], softev), ...
  @(model,  softev) argout(2, @noisyMixModelInferNodes, model, [], softev), ...
  @(model, softev) argout(2, @noisyMixModelInferNodes, model, [], softev), ...
    @(model, softev) argout(2, @treegmInferNodes, model, [], softev)
    };



logprobMethods = {
  @(model, X) mixModelLogprob(model.mixmodel, X), ...
  @(model, X) mixModelLogprob(model.mixmodel, X), ...
  @(model, X) mixModelLogprob(model.mixmodel, X), ...
  @(model, X) treegmLogprob(model, X)
  };


%% Training p(labels)

Nmethods = numel(methodNames);
models = cell(1, Nmethods);
labels = train.presence_truth(trainNdx, objectNdx);

% Train up p(labels)
for m=1:Nmethods
  fprintf('fitting %s\n', methodNames{m});
  models{m} = fitMethods{m}(labels);
end


%{
% Visualize tree
folder =  fileparts(which(mfilename()) 
folder = '/home/kpmurphy/Dropbox/figures';
% for some reason, the directed graph is much more readable
graphviz(model.edge_weights, 'labels', train.names, 'directed', 1, ...
  'filename', fullfile(folder, 'SUN09treeNeg'));
%}

%{
% Visualize mix model
model = models{2};
K = model.mixmodel.nmix;
[nr,nc] = nsubplots(K);
figure;
for k=1:K
  T = squeeze(model.mixmodel.cpd.T(k,2,:));
  subplot(nr, nc, k)
  bar(T);
  [probs, perm] = sort(T, 'descend');
  memberNames = sprintf('%s,', train.names{perm(1:5)})
  title(sprintf('%5.3f, %s', model.mixmodel.mixWeight(k), memberNames))
end
%}

%% Probability of labels
% See if the models help with p(y(1:T))
ll_indep = zeros(1, Ntest); %#ok
ll_model = zeros(Ntest, Nmethods);
labels = test.presence_truth(testNdx, objectNdx)+1; % 1,2

logPrior = [log(1-priorProb+eps); log(priorProb+eps)];
ll = zeros(Ntest, Nobjects);
for j=1:Nobjects
  ll(:,j) = logPrior(labels(:, j), j);
end
ll_indep = sum(ll,2);

for m=1:Nmethods
  ll_model(:, m) = logprobMethods{m}(models{m}, labels);
end

ll = [sum(ll_indep) sum(ll_model,1)];
figure;
%bar(-ll)
plot(-ll, 'x', 'markersize', 12, 'linewidth', 2)
legendstr = {'indep', methodNames{:}};
set(gca, 'xtick', 1:numel(legendstr))
set(gca, 'xticklabel', legendstr)
title('negloglik of test labels')
axis_pct

end



%% Train  p(scores | labels) 
%obstype = 'localev';
obstype = 'gauss';


labels = train.presence_truth(trainNdx, objectNdx);
scores = train.maxscores(trainNdx, objectNdx);
[obsmodel] = obsModelFit(labels, scores, obstype);


%% Check the reasonableness of the local observation model for class c
% note that p(score|label) is same for all models
%{
model = obsmodel;
for c=[1 110]

% Empirical distributon
ndx=(train.presence_truth(:,c)==1);
figure;
%plot(train.maxscores(ndx,c));
hist(train.maxscores(ndx,c))
title(sprintf('scores when class %s present, mean %5.3f, var %5.3f', ...
  train.names{c}, mean(train.maxscores(ndx,c)), var(train.maxscores(ndx,c))));
figure;
%plot(train.maxscores(~ndx,c));
hist(train.maxscores(~ndx,c))
title(sprintf('scores when class %s absent, mean %5.3f, var %5.3f', ...
  train.names{c}, mean(train.maxscores(~ndx,c)), var(train.maxscores(~ndx,c))));

% Model distribution
figure;
[h,bins]=hist(train.maxscores(:,c));
bar(bins, normalize(h))
hold on;
xmin = min(train.maxscores(:,c));
xmax = max(train.maxscores(:,c));
xvals = linspace(xmin, xmax, 100);
mu = model.localCPDs{c}.mu;
Sigma = squeeze(model.localCPDs{c}.Sigma);
p = gaussProb(xvals, mu(1), Sigma(1));
plot(xvals, p, 'b:');
p = gaussProb(xvals, mu(2), Sigma(2));
plot(xvals, p, 'r-');
title(sprintf('distribution of scores for %s', train.names{c}))
end
%}



%% Inference
presence_indep = zeros(Ntest, Nobjects);
presence_model = zeros(Ntest, Nobjects, Nmethods);

features = test.maxscores(testNdx, objectNdx); %Ncases*Nnodes*Ndims
softevBatch = localEvToSoftEvBatch(obsmodel, features);

for m=1:Nmethods
  fprintf('running method %s with %s\n', methodNames{m}, obstype);
  
  for n=1:Ntest
    frame = testNdx(n);
    if (n==1) || (mod(n,500)==0), fprintf('testing image %d of %d\n', n, Ntest); end
    
    %{
    img = imread(fullfile(HOMEIMAGES, test.folder{frame}, test.filename{frame}));
    figure(1); clf; image(img)
    trueObjects = sprintf('%s,', test.names{find(test.presence_truth(frame,:))});
    title(trueObjects)
    %}
    
    softev = softevBatch(:,:,n); % Nstates * Nnodes * 1
    [presence_indep(n,:)] = features(n, :);
    %[presence_indep(n,:)] = softev(2, :);
    bel = infMethods{m}(models{m}, softev);
    presence_model(n,:,m) = bel(2,:);  
  end
end

%% Performance evaluation


[styles, colors, symbols, plotstr] =  plotColors(); %#ok

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

for e=1:numel(evalFns)
  evalPerf = evalFns{e};
  perfStr = evalNames{e};
  
  score_indep = zeros(1, Nobjects);
  score_models = zeros(Nobjects, Nmethods);
  for cc=1:Nobjects
    c = objectNdx(cc);
    [score_indep(cc)] = evalPerf(presence_indep(testNdx,c), test.presence_truth(testNdx,c));
    for m=1:Nmethods
      score_models(cc,m) = evalPerf(presence_model(testNdx,c,m), test.presence_truth(testNdx,c));
    end
  end
  
  % plot mean performance of each method
  mean_perf_indep = mean(score_indep);
  mean_perf_models = zeros(1, Nmethods);
  for m=1:Nmethods
    mean_perf_models(m) = mean(score_models(:,m));
  end
  figure
  %bar([mean_perf_indep mean_perf_models])
  plot([mean_perf_indep mean_perf_models], 'x', 'markersize', 12, 'linewidth', 2)
  legendstr = {'indep', methodNames{:}};
  set(gca, 'xtick', 1:numel(legendstr))
  set(gca, 'xticklabel', legendstr)
  title(sprintf('mean %s', perfStr))
  axis_pct
  
  % Plot performance for each method vs category on same graph
  figure;
  % list objects in decreasing order of performance based on indep model
  [~, perm] = sort(score_indep, 'descend');
  plot(score_indep(perm), plotstr{1}, 'linewidth', 2);
  hold on
  legendstr{1} = sprintf('indep, mean=%5.3f', mean_perf_indep);
  for m=1:Nmethods
    mm = m+1;
    plot(score_models(perm,m), plotstr{mm}, 'linewidth', 2);
    legendstr{mm} = sprintf('%s, mean=%5.3f', methodNames{m}, mean_perf_models(m));
  end
  legend(legendstr)
  ylabel(perfStr)
  xlabel('category')
  
  % plot improvement over baseline for each method as separate figs
  for m=1:Nmethods
    figure;
    [delta, perm] = sort(score_models(:,m) - score_indep(:), 'descend');
    bar(delta)
    str = sprintf('mean of %s using indep %5.3f, using %s  %5.3f', ...
      perfStr, mean_perf_indep, methodNames{m},  mean_perf_models(m));
    disp(str)
    title(str)
    xlabel('category')
    ylabel(sprintf('improvement in %s over baseline', perfStr))
  end
  
end % for e