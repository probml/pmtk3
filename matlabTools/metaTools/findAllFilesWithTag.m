function m = findAllFilesWithTag(tag, returnFullPath, root)
% Find all of the files in the PMTK directory structure with a certain tag
% See also pmtkTagReport
%%

% This file is from pmtk3.googlecode.com

if nargin < 2, returnFullPath = false; end
if nargin < 3, root = pmtk3Root(); end
if tag(1) == '%', tag(1) = []; end
tag = strtrim(tag);
allfiles = mfiles(root, 'useFullPath', returnFullPath);
m = {};
for i=1:numel(allfiles)
    fpath = which(allfiles{i});
    if isempty(fpath), continue; end
    if(hasTag(fpath, tag))
        m = [m, allfiles{i}]; %#ok
    end
end
m = m';
end
