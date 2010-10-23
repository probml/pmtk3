function changeCopyrightMatlabTools(oldStr, newStr, fname)
%% Modify the copyright line in every matlabTools file
% or in just the specified file. The oldStr should be exactly as it appears
% in the file(s), including case, spaces, and leading '%' chars.
%%

% This file is from matlabtools.googlecode.com

if nargin > 2
    searchAndReplaceLine(fname, oldStr, newStr);
else
    flist = filelist(matlabToolsRoot(), '*.m', true);
    for i=1:numel(flist)
        searchAndReplaceLine(flist{i}, oldStr, newStr);
    end
end
end
