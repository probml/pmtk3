function insertCopyrightPmtk(fname)
%% Insert a copyright notice into every pmtk3 .m file
% or into just the specified file. 
%%

% This file is from pmtk3.googlecode.com

exclusions = {'docs'};
text = 'This file is from pmtk3.googlecode.com';

if nargin > 0
    insertCopyright(text, fname); 
else
    flist = filelist(pmtk3Root(), '*.m', true);
    for i=1:numel(exclusions)
       flist = setdiff(flist, filelist(fullfile(pmtk3Root(), exclusions{i}), '*.m', true));  
    end
    for i=1:numel(flist)
        fprintf('inserting into %s\n', flist{i}); 
        insertCopyright(text, flist{i}); 
    end
end
end
