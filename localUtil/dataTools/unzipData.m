function unzipData(dataSource, dest, threshold)
%% Unzip all of the data to another directory, without the zip or svn files
% If threshold is specified, data is split into two by threshold size in
% MB, creating "big" and "small" directories. 
%
% dataSource is the location of the pmtkData local copy of the svn
% repository.
%
%% Example
%
% unzipData('C:\pmtkData', 'C:\users\Matt\Desktop\', 5);
%%

% This file is from pmtk3.googlecode.com


SetDefaultValue(1, 'dataSource', 'C:\pmtkData'); 

zipFiles = filelist(dataSource, '*.zip', true); 

tocopy = cellfun(@(c)ismember(c, dirs(dataSource)), filenames(zipFiles));
zipFiles = zipFiles(tocopy); 

destDir = fullfile(dest, 'pmtkData'); 
if ~(exist(destDir, 'file') == 7)
    mkdir(destDir); 
end

if nargin < 3
    big = fullfile(destDir, 'big');
    small = fullfile(destDir, 'small'); 
    mkdir(big);
    mkdir(small);
    for z=1:numel(zipFiles)
        d = dir(zipFiles{z}); 
        sz = d.bytes/(1024*1024); 
        if sz <= threshold
            finalDest = fullfile(destDir, 'small');
        else
            finalDest = fullfile(destDir, 'big');
        end
        unzip(zipFiles{z}, finalDest); 
    end
    
else
    for z=1:numel(zipFiles)
        unzip(zipFiles{z}, destDir); 
    end
end


end
