function exportsvn(source, dest, exclusions, createEmpty)
% Export and zip up a local svn repository ignoring .svn files
%   SOURCE:  path to the root directory of the svn source
%   DEST:    path to destination including zip file name
%   EXCLUSIONS: a cell array of directories to exclude from the
%               zip file. These should be relative to the root directory
%   EXAMPLE:
%
% exportsvn('C:\pmtk3', 'C:\users\matt\Desktop\pmtk3.zip', {'docs'})

if nargin < 3, exclusions = {}; end
if nargin < 4, createEmpty = {}; end

destpath = fileparts(dest);
system(sprintf('svn export %s %s', source, fullfile(destpath, 'tmp')));
for i=1:numel(exclusions)
    ex = fullfile(destpath, 'tmp', exclusions{i});
    if exist(ex, 'file')
        fprintf('%s excluded\n', exclusions{i});
        system(sprintf('rmdir /Q /S %s', ex));
    end
end
for i=1:numel(createEmpty)
   fprintf('adding emtpy directory: %s\n', createEmpty{i}); 
   mkdir(fullfile(destpath, 'tmp', createEmpty{i}));  
end


zip(dest, fullfile(destpath, 'tmp', '*'));
[err, output] = system(sprintf('rmdir /Q /S %s', fullfile(destpath, 'tmp')));
if err
    error('svn export failed:%s\n', output); 
end
end