


% Process the data from
% http://web.mit.edu/~myungjin/www/HContext.html

% needs: extractPresence, extractMaxDetScore, extractMaxDetScoreFromText
% xticklabel_rotate

dataDir = '/home/kpmurphy/LocalDisk/SUN09/';
HOMEIMAGES = fullfile(dataDir, 'Images');
HOMEANNOTATIONS = fullfile(dataDir, 'Annotations');
sun_folder = 'static_sun09_database';
figFolder = '/home/kpmurphy/Dropbox/figures';
saveFolder = '/home/kpmurphy/pmtkdata/sceneContextSUN09';

%% Ground truth presence/ absence

%{
 Contents of groundTruth
categories: [1x1 struct]
               Dtest: [1x4317 struct]
    DtrainingObjects: [1x28472 struct]
       Doutofcontext: [1x42 struct]
           Dtraining: [1x4367 struct]
%}

objectCategories = load(fullfile(dataDir, 'dataset', 'sun09_objectCategories'));
names = [objectCategories.names];
data.names = names;

fname = fullfile(dataDir, 'dataset', 'sun09_groundTruth');
%names2 = load(fname, 'categories');
%assert(isequal(names, names2))

load(fname, 'Dtraining')
load(fname, 'Dtest')

[data.train.presence, data.train.filenames] = extractPresence(Dtraining, names);
[data.test.presence, data.test.filenames] = extractPresence(Dtest, names);

% Check that everything makes visual sense!
for i=1:3
figure(1); clf
LMplot(Dtraining, i, HOMEIMAGES); % requires labelme toolbox
figure(2); clf
img = imread(fullfile(HOMEIMAGES, sun_folder, data.train.filenames{i}));
imshow(img)
present = sprintf('%s,', names{find(data.train.presence(i, :))});
title(present)
pause
end

clear Dtraining
clear Dtest

% plot prior
Npresent = sum(data.train.presence, 1);
[Ntrain Nobjects] = size(data.train.presence);
priorProb = Npresent/Ntrain;
figure; bar(priorProb);
title('prior probability')
%xticklabelRot(train.names, 45, 8)
xticklabel_rotate(1:Nobjects, 90, data.names, 'fontsize', 8)

% plot data
figure; imagesc(data.train.presence); colormap(gray)
xlabel('categories')
ylabel('training case')
title('presence or absence')
% Label common objects
common=find(mean(data.train.presence,1)>0.25);
str = sprintf('%s,', data.names{common});
title(sprintf('%s', str));
xticklabel_rotate(common, 90, data.names(common), 'fontsize', 8);


%print(gcf, '-dpng', fullfile(figFolder, 'SUN09presenceTrain.png'))


 


%% Detectors

%{

 DdetectorTest            1x4317            1685394030  struct              
  DdetectorTraining        1x4367            1707944820  struct              
  HOMEANNOTATIONS          1x42                      84  char                
  HOMEIMAGES               1x37                      74  char                
  MaxNumDetections         1x1                        8  double              
  dataDir                  1x31                      62  char                
  logitCoef              111x1                    14208  cell                
  validcategories          1x111                  13696  cell 
%}
% Extract max detector score for each frame

fname  = fullfile(dataDir, 'dataset', 'sun09_detectorOutputs');
load(fname, 'DdetectorTraining');
load(fname, 'logitCoef');
[data.train.detect_maxprob, data.train.detect_maxscores] = ...
  extractMaxDetScore(DdetectorTraining, names, logitCoef);
clear DdetectorTraining



% Plot
figure; imagesc(data.train.detect_maxscores); colorbar
figure; imagesc(data.train.detect_maxprob); colorbar
xlabel('categories')
ylabel('training case')
title('max score of detector')
% Label objects whose detectors fire a lot
common=find(mean(data.train.detect_maxprob,1)>0.1);
str = sprintf('%s,', data.names{common});
title(sprintf('max detector score\n%s', str));
xticklabel_rotate(common, 90, data.names(common), 'fontsize', 8);
%print(gcf, '-dpng', fullfile(figFolder, 'SUN09maxprobTrain.png'))


%{
% Sanity check
% This check fails because the images are not listed
% in alphabetical order in the dictionary
Ntrain = size(data.train.detect_maxscores,1);
[maxscores_train, files] = extractMaxDetScoreFromText(names, Ntrain, 1, dataDir);
assert(approxeq(maxscores_train, data.train.detect_maxscores))
assert(isequal(files, data.train.filenames))
%}

load(fname, 'DdetectorTest');
[data.test.detect_maxprob, data.test.detect_maxscores] = ...
  extractMaxDetScore(DdetectorTest, names, logitCoef);
clear DdetectorTest




%% Save data


fname = fullfile(saveFolder, 'SUN09data.mat');
save(fname, 'data')


% Now save data in text format for non matlab users

fid = fopen(fullfile(saveFolder, 'SUN09names.txt'), 'w');
for c=1:numel(names)
  fprintf(fid, '%s,', data.names{c});
end
fclose(fid)

dlmwrite(fullfile(saveFolder, 'SUN09train_presence.csv'), data.train.presence, ...
  'precision', '%d')

dlmwrite(fullfile(saveFolder, 'SUN09train_detect_maxscores.csv'), data.train.detect_maxscores, ...
  'precision', '%5.3f')

dlmwrite(fullfile(saveFolder, 'SUN09train_detect_maxprob.csv'), data.train.detect_maxprob, ...
  'precision', '%5.3f')


dlmwrite(fullfile(saveFolder, 'SUN09test_presence.csv'), data.test.presence, ...
  'precision', '%d')

dlmwrite(fullfile(saveFolder, 'SUN09test_detect_maxscores.csv'), data.test.detect_maxscores, ...
  'precision', '%5.3f')

dlmwrite(fullfile(saveFolder, 'SUN09test_detect_maxprob.csv'), data.test.detect_maxprob, ...
  'precision', '%5.3f')

coef = zeros(2,Nobjects);
for j=1:Nobjects
  coef(:,j) = logitCoef{j}';
end
dlmwrite(fullfile(saveFolder, 'SUN09logitCoef.csv'), coef,  'precision', '%5.3f')
