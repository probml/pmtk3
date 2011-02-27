function changeCopyrightPmtk(oldStr, newStr, fname)
%% Modify the copyright line in every PMTK3 file
% or in just the specified file. The oldStr should be exactly as it appears
% in the file(s), including case, spaces, and leading '%' chars.
%%

% This file is from pmtk3.googlecode.com

if nargin > 2
    searchAndReplaceLine(fname, oldStr, newStr);
else
    flist = filelist(pmtk3Root(), '*.m', true);
    for i=1:numel(flist)
        searchAndReplaceLine(flist{i}, oldStr, newStr);
    end
end
end
