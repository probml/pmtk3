function insertCopyrightMatlabTools(fname)
%% Insert a copyright notice into every matlabTools .m file
% or into just the specified file.
%%

% This file is from matlabtools.googlecode.com

text = 'This file is from matlabtools.googlecode.com';

if nargin > 0
    insertCopyright(text, fname);
else
    flist = filelist(matlabToolsRoot(), '*.m', true);
    for i=1:numel(flist)
        fprintf('inserting into %s\n', flist{i}); 
        insertCopyright(text, flist{i});
    end
end
end
