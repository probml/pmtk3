 

if isunix
  figFolder = '/home/kpmurphy/Dropbox/figures/sceneContext';
end
if ismac
  figFolder = '/Users/kpmurphy/Dropbox/figures/sceneContext';
end


% Get ground truth
setSeed(0);
loadData('sceneContextSUN09', 'ismatfile', false)
load('SUN09data')
objectnames  = data.names;
Nobjects = numel(objectnames);
test.presence = data.test.presence;
[Ntest, Nobj] = size(test.presence);



% Read in scores of wasabi
dataFolder = '/home/kpmurphy/scratch/wasabiLabelme';
fileNames = dirPMTK(dataFolder);
Nmethods = numel(fileNames)+1;
presence_model = zeros(Ntest, Nobjects, Nmethods);
methodNames = cell(1, Nmethods+1);
methodNames{1} = 'baseline';
presence_model(:,:,1) = data.test.detect_maxprob;
for m=2:Nmethods
  fname = fullfile(dataFolder, fileNames{m-1});
  methodNames{m} = fileNames{m-1}(1:end-length('results.'));
  scores = load(fname); % read text file
  presence_model(:,:,m) = scores;
end




%% Performance evaluation
mean_auc_models = zeros(Nfolds, Nmethods);
mean_eer_models = zeros(Nfolds, Nmethods);
auc_models = nan(Nobjects, Nmethods);
eer_models = nan(Nobjects, Nmethods);
absent = zeros(1, Nobjects);
for c=1:Nobjects
  % If the object is absent in a given fold, we may get NaN for
  % the performance. We want to exclude these from the evaluation.
  absent(c) = all(test.presence(:,c)==0);
  if absent(c), continue; end
  for m=1:Nmethods
    [auc_models(c,m), fpr, tpr,  eer_models(c,m)] = ...
      rocPMTK(presence_model(:,c,m), test.presence(:,c)); %#ok
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
%set(gca, 'xticklabel',  methodNames(ndx))
xticklabelRot(methodNames(ndx), 45)
title(sprintf('AUC averaged over classes'))
%fname = fullfile(figFolder, sprintf('boxplot-auc.png'));
%print(gcf, '-dpng', fname);
  
% Mean EER
figure;
if Nfolds==1
  plot(mean_eer_models, 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  boxplot(mean_eer_models(:,ndx))
end
set(gca, 'xtick', 1:numel(ndx))
xticklabelRot(methodNames(ndx), 45)
%set(gca, 'xticklabel', methodNames(ndx))
title(sprintf('EER averaged over classes'))
%fname = fullfile(figFolder, sprintf('boxplot-eer.png'));
%print(gcf, '-dpng', fname);
  

 