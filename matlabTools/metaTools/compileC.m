function compileC(root, excludedNames)
% Try and compile all mexable c-files in the directory structure that
% have not already been compiled. 
%
% excludedNames is a cell array of strings. A file is excluded if it
% contains one of these strings in its absolute path name, thus it can be
% the name of a file, directory, or parent directory. 
%%
% PMTKneedsMatlab 
%%

% This file is from pmtk3.googlecode.com

if nargin < 1, root = pmtk3Root(); end

if nargin < 2
    excludedNames = {'external'  % most external packages require custom mex linking 
                    };
end
cfiles = cfilelist(root);
for i=1:numel(excludedNames)
   ex = cellfun(@(c)isSubstring(excludedNames{i}, c), cfiles); 
   cfiles(ex) = []; 
end

for j=1:numel(cfiles)
    try
        cfile = cfiles{j};
        fname = fnameOnly(cfile);
        if ~(exist(fname, 'file') == 3)
            cd(fileparts(cfile));
            fprintf('Compiling %s\n',cfile);
            mex(cfile);
        end
    catch ME
        fprintf('Could not compile %s\n', cfile);
    end
end
end
