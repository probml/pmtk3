
% Fit joint models to the tags and visualize them 

%% Data
loadData('sceneContextSUN09', 'ismatfile', false)
load('SUN09data')

train = data.train;
test = data.test;
[Ntrain, Nnodes] = size(train.presence);
names = data.names;


%% Visualize data
%{
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
%}



folder = '/home/kpmurphy/Dropbox/figures';
% folder =  fileparts(which(mfilename())



% indep model
Npresent = sum(train.presence, 1);
priorProb = Npresent/Ntrain;



%{
% Fit a depnet to the labels
model = depnetFit(data.train.presence, 'nodeNames', data.names, ...
  'method', 'ARD')
graphviz(model.G, 'labels', model.nodeNames, 'directed', 1, ...
  'filename', fullfile(folder, 'SUN09depnetARDvb'));


% Fit a depnet to the labels
model2 = depnetFit(data.train.presence, 'nodeNames', data.names, 'method', 'MI')
graphviz(model2.G, 'labels', model.nodeNames, 'directed', 0, ...
  'filename', fullfile(folder, 'SUN09depnetMI'));
%}

% Fit a dgm
model3 = dgmFit(data.train.presence, 'nodeNames', data.names);
graphviz(model3.G, 'labels', model.nodeNames, 'directed', 1, ...
  'filename', fullfile(folder, 'SUN09dag'));




%{
% Fit tree to the labels
model = treegmFit(data.train.presence);
% The tree is undirected, but for some reason, gviz makes directed graphs
% more readable than undirected graphs
graphviz(model.edge_weights, 'labels', train.names, 'directed', 1, ...
  'filename', fullfile(folder, 'SUN09treeNeg'));
 
  %}
  
  %{
% Visualize mix model
  
  
  if isfield(models{1}, 'mixmodel') && models{1}.mixmodel.nmix==1
    assert(approxeq(priorProb, models{1}.mixmodel.cpd.T(1,2,:)))
    priorProb(1:5)
    squeeze(models{1}.mixmodel.cpd.T(1,2,1:5))
  end
 
  
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
  
