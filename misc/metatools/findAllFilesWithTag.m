function m = findAllFilesWithTag(tag, returnFullPath)
% Find all of the files in the PMTK directory structure that have the specified
% tag.
%%
if nargin < 2, returnFullPath = false; end
if tag(1) == '%', tag(1) = []; end
tag = strtrim(tag);
allfiles = mfiles(pmtk3Root(), returnFullPath);
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