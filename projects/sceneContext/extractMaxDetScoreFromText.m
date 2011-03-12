function [maxscores, files] = extractMaxDetScoreFromText(names, N, istraining, base)
% maxscores(n,c) = max detector score for frame n, class c

%base = '/home/kpmurphy/LocalDisk/SUN09/';
%(test/train)/objectCategory/imageName.txt

% each line of these files contains [x1 y1 x2 y2 score]
% for each detected window

if istraining
  str = 'train';
else
  str = 'test';
end
Nobjects = numel(names);
maxscores = nan(N, Nobjects);

for c=1:Nobjects
  obj = names{c};
  fprintf('extracting max score from %s\n', obj);
  folder = fullfile(base, str, obj);
  files = dirPMTK(folder);
  for n=1:numel(files)
    fname = fullfile(base, str, obj, files{n});
    fprintf('extracting max score from image %d %s\n', n, fname);
    data = load(fname);
    if ~isempty(data)
      maxscores(n,c) = max(data(:,5));
    end
  end
end

end

