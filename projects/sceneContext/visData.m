

loadData('sceneContextSUN09', 'ismatfile', false)
load('SUN09data')

train = data.train;
test = data.test;
[Ntrain, Nnodes] = size(train.presence);
names = data.names;


% Presence
figure; imagesc(data.train.presence); colormap(gray)
xlabel('categories')
ylabel('training case')
title('presence or absence')
% Label common objects
thresh = 0.2;
common=find(mean(data.train.presence,1)>thresh);
str = sprintf('%s,', data.names{common});
title(sprintf('presence prob > %5.3f\n%s', thresh, str));
xticklabel_rotate(common, 90, data.names(common), 'fontsize', 8);
%print(gcf, '-dpng', fullfile(folder, 'SUN09presenceTrain.png'))

% Scores
figure; imagesc(data.train.detect_maxprob); colorbar
xlabel('categories')
ylabel('training case')
title('max score of detector')
% Label objects whose detectors fire a lot
thresh = 0.1;
common=find(mean(data.train.detect_maxprob,1)>0.1);
str = sprintf('%s,', data.names{common});
title(sprintf('max detector prob > %5.3f\n%s', thresh, str));
xticklabel_rotate(common, 90, data.names(common), 'fontsize', 8);
%print(gcf, '-dpng', fullfile(folder, 'SUN09probTrain.png'))
