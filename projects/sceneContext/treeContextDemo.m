
% Try to reproduce ROC curves from
% Exploiting Hierarchical Context on a Large Database of Object Categories
% Choi et al, 2010

loadData('sceneContextSUN09', 'ismatfile', false)
load('SUN09trainData')
load('SUN09testData')

model = treegmFit(train.presence_truth, train.maxscores, 'gauss');

%% Check the reasonableness of the local observation model for class c
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
p = gaussProb(xvals, model.localMu(c,1), model.localSigma(c,1));
plot(xvals, p, 'b:');
p = gaussProb(xvals, model.localMu(c,2), model.localSigma(c,2));
plot(xvals, p, 'r-');
title(sprintf('distribution of scores for %s', train.names{c}))
end

%% Inference
[Ntest, Nobjects] = size(test.presence_truth);
presence_tree = zeros(Ntest, Nobjects);
presence_indep = zeros(Ntest, Nobjects);
for n=1:Ntest
    if mod(n,10)==0, fprintf('testing image %d of %d\n', n, Ntest); end
    localev = test.maxscores(n,:); % 1*Nnodes
    [logZ, nodeBel] = treegmInferNodes(model, localev);
    [presence_tree(n,:)] = nodeBel(2,:);
    [presence_indep(n,:)] = localev;
end
    
%% ROC
ndx = 1:Ntest;
for c=1:Nobjects
   [aROCtree(c)] = figROC(presence_tree(ndx,c), test.presence_truth(ndx,c));
   [aROCIndep(c)] = figROC(presence_indep(ndx,c), test.presence_truth(ndx,c));  
   [prRecall, prPrecision, foo, aucTree(c)]= precisionRecall(presence_tree(ndx,c)', ...
       test.presence_truth(ndx,c)');
   [prRecallc, prPrecisionc, foo, aucTreeIndep(c)] = precisionRecall(presence_indep(ndx,c)', ...
       test.presence_truth(ndx,c)');
end

figure;
plot(aROCtree, 'r-');
hold on
plot(aROCIndep, 'b:', 'linewidth', 2);
legend('tree', 'indep')
ylabel('area under ROC')
xlabel('category')

figure;
[delta, perm] = sort(aROCtree - aROCIndep, 'descend');
bar(delta)
title('Improvement in AUC by using tree')

