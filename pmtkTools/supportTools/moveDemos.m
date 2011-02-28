
% Move files from demos/bookDemos/folder/foo.m
% to demos/ foo.m

% This file is from pmtk3.googlecode.com

demoDir = fullfile(pmtk3Root(), 'demos')
folders = dirPMTK(fullfile(demoDir, 'otherDemos'));
for fi=1:length(folders)
  folder = folders{fi};
  files = dirPMTK(fullfile(demoDir, 'otherDemos', folder, '*.m'));
  for fi2=1:length(files)
    file = files{fi2};
    src = fullfile(demoDir, 'otherDemos', folder, file);
    destn = fullfile(demoDir, file);
    cmd = sprintf('copy %s %s\n', src, destn)
    system(cmd)
  end
end

