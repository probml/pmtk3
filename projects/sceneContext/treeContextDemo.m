
% Try to reproduce ROC curves from
% Exploiting Hierarchical Context on a Large Database of Object Categories
% Choi et al, 2010

loadData('sceneContextSUN09', 'ismatfile', false)
load('SUN09trainData')
load('SUN09testData')


treeModel = treegmFit(train.presence_truth, train.maxscores, 'gauss');


%{
folder =  fileparts(which(mfilename()) 
folder = '/home/kpmurphy/Dropbox/figures';
% for some reason, the directed graph is much more readable
graphviz(model.edge_weights, 'labels', train.names, 'directed', 1, ...
  'filename', fullfile(folder, 'SUN09treeNeg'));
%}


%% Check the reasonableness of the local observation model for class c
%{
for c=[1 110]
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

figure;
[h,bins]=hist(train.maxscores(:,c));
bar(bins, normalize(h))
hold on;
xmin = min(train.maxscores(:,c));
xmax = max(train.maxscores(:,c));
xvals = linspace(xmin, xmax, 100);
mu = treeModel.localCPDs{c}.mu;
Sigma = squeeze(model.localCPDs{c}.Sigma);
p = gaussProb(xvals, mu(1), Sigma(1));
plot(xvals, p, 'b:');
p = gaussProb(xvals, mu(2), Sigma(2));
plot(xvals, p, 'r-');
title(sprintf('distribution of scores for %s', train.names{c}))
end
%}

%% Inference
[Ntest, Nobjects] = size(test.presence_truth);
presence_tree = zeros(Ntest, Nobjects);
presence_indep = zeros(Ntest, Nobjects);
for n=1:Ntest
    if mod(n,10)==0, fprintf('testing image %d of %d\n', n, Ntest); end
    localev = test.maxscores(n,:); % 1*Nnodes
    [presence_indep(n,:)] = localev;
    [logZ, nodeBel] = treegmInferNodes(treeModel, localev);
    [presence_tree(n,:)] = nodeBel(2,:);
end
    
%% ROC
ndx = 1:Ntest;
for c=1:Nobjects
  [aROCIndep(c)] = figROC(presence_indep(ndx,c), test.presence_truth(ndx,c));
  [aROCtree(c)] = figROC(presence_tree(ndx,c), test.presence_truth(ndx,c));
  %{
   [prRecall, prPrecision, foo, aucTree(c)]= precisionRecall(presence_tree(ndx,c)', ...
       test.presence_truth(ndx,c)');
   [prRecallc, prPrecisionc, foo, aucTreeIndep(c)] = precisionRecall(presence_indep(ndx,c)', ...
       test.presence_truth(ndx,c)');
  %}
end

[styles, colors, symbols, str] =  plotColors();

figure;
plot(aROCIndep, str{1}, 'linewidth', 2);
hold on
plot(aROCtree, str{2}, 'linewidth', 2);
legendstr = {'indep', 'tree'};
legend(legendstr)
ylabel('area under ROC')
xlabel('category')


figure;
[delta, perm] = sort(aROCtree - aROCIndep, 'descend');
bar(delta)
title('Improvement in AUC by using tree')

