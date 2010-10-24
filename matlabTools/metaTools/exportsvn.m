function exportsvn(source, dest, exclusions, createEmpty)
% Export and zip up a local svn repository ignoring .svn files
%   SOURCE:  path to the root directory of the svn source
%   DEST:    path to destination including zip file name
%   EXCLUSIONS: a cell array of directories to exclude from the
%               zip file. These should be relative to the root directory
%   EXAMPLE:
%
% exportsvn('C:\pmtk3', 'C:\users\matt\Desktop\pmtk3.zip', {'docs'})

% This file is from pmtk3.googlecode.com


if nargin < 3, exclusions = {}; end
if nargin < 4, createEmpty = {}; end

destpath = fileparts(dest);
[err1, output] = system(sprintf('svn export %s %s', source, fullfile(destpath, 'tmp')));
for i=1:numel(exclusions)
    ex = fullfile(destpath, 'tmp', exclusions{i});
    if exist(ex, 'file')
        fprintf('%s excluded\n', exclusions{i});
        system(sprintf('rmdir /Q /S %s', ex));
    end
end

readmeText = {'This directory is left intentionally empty, and filled on demand.'};
for i=1:numel(createEmpty)
   fprintf('adding empty directory: %s\n', createEmpty{i}); 
   emptyPath = fullfile(destpath, 'tmp', createEmpty{i});
   mkdir(emptyPath);  
   writeText(readmeText, fullfile(emptyPath, 'readme.txt')); 
end


zip(dest, fullfile(destpath, 'tmp', '*'));
err2 = system(sprintf('rmdir /Q /S %s', fullfile(destpath, 'tmp')));
if err1 || err2
    error('svn export failed:%s\n', output); 
end
end
