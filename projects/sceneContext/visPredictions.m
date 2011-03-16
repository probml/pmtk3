
function visPredictions(truePresence, probPresence, objectnames, methodNames, filenames, cutoffs, Dtest)

% visualize some predictions -  needs original images
% We plot labels using the EER cutoff
% truePresence(n,c), probPresence(n,c,m), objectNames{c}, methodNames{m}

if nargin < 7, Dtest = []; end

dataDir = '/home/kpmurphy/LocalDisk/SUN09/';
HOMEIMAGES = fullfile(dataDir, 'Images');
%HOMEANNOTATIONS = fullfile(dataDir, 'Annotations');
sun_folder = 'static_sun09_database';
figFolder = '/home/kpmurphy/Dropbox/figures/sceneContext';

%[styles, colors, symbols, str] =  plotColors();
%colors = hsv(15);
colors = pmtkColors;

frames = [1,100,500,1000,2000];
basefig = 10;
for frame=frames(:)'
  
  img = imread(fullfile(HOMEIMAGES, sun_folder, filenames{frame}));
  truePresent = find(truePresence(frame,:));
  trueObjects = sprintf('%s,', objectnames{truePresent}); %#ok
  titlestr = sprintf('test %d: %s', frame, trueObjects); 
  figure(basefig+1); clf;
  if isempty(Dtest)
    image(img)
  else
    LMplot(Dtest, frame, HOMEIMAGES);
  end
  title(titlestr)
  fname = fullfile(figFolder, sprintf('testimg%d-truth.png', frame));
  print(gcf, '-dpng', fname);
  

  for m=1:numel(methodNames)
    figure(basefig + m+1); clf; image(img); hold on
    pp = colvec(squeeze(probPresence(frame,:,m)));
    %thresh = 0.1*cutoffs(:, m);
    thresh = cutoffs(:, m);
    predPresent = find(pp > thresh);
    predObjects = sprintf('%s,', objectnames{predPresent});
    title(sprintf('predictions by %s\n%s', methodNames{m}, predObjects));
    
    % extract location of max detection from text file of detector output
    % and plot bounding box
    %base = '/home/kpmurphy/LocalDisk/SUN09/';
    % (test/train)/objectCategory/imageName.txt
    h = [];
    for cc=1:numel(predPresent)
      c = predPresent(cc);
      [path, basename, extension,version] = fileparts(filenames{frame}); %#ok
      fname = fullfile(dataDir, 'test', objectnames{c}, sprintf('%s.txt', basename));
      data = load(fname);
      Ncolors = numel(colors); %size(colors,1);
      col = colors{wrap(c, Ncolors)};
      if ~isempty(data)
        [~, best] = max(data(:,5));
        bbox = data(best, 1:4); %[x1 y1 x2 y2 score], top left, bottom right
        x1 = bbox(1); y1 = bbox(2); x2 = bbox(3); y2 = bbox(4);
        X = [x1 x2 x2 x1];
        Y = [y1 y1 y2 y2];
        h(cc) = plot([X X(1)],[Y Y(1)], 'LineWidth', 3, 'color', col);
        %h(cc) = rectangle('position', [x1 y1 x2-x1 y2-y1], ...
        %  'edgecolor', colors(cc), 'linewidth', 3);
      end
    end
    legend(h, objectnames{predPresent})
    
    fname = fullfile(figFolder, sprintf('testimg%d-%s.png', frame, methodNames{m}));
    print(gcf, '-dpng', fname);
    
  end % for m
  
  pause
end % for frame


end