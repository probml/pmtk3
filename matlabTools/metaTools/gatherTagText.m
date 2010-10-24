function C = gatherTagText(R, tag, fileNdx)
%% Gather the tag text from R=tagReport() into a cell array
% C{i} is the text associated with the specified tag for
% R.files{fileNdx(i)}, and is blank if the file has not such tag. 
% If fileNdx is not specified, all files are searched. 
%%

% This file is from pmtk3.googlecode.com

if nargin < 3
    fileNdx = 1:numel(R.files); 
end

nfiles = numel(fileNdx); 
C = cell(nfiles, 1); 
tags    = R.tags(fileNdx); 
tagtext = R.tagtext(fileNdx); 
for i=1:nfiles
    ndx = cellfind(tags{i}, tag);
    if isempty(ndx), continue; end
    C(i) = tagtext{i}(ndx);
end
end
