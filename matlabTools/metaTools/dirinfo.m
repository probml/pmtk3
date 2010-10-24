function info = dirinfo(directory)
% Collect information about the files in a directory structure
%Recursively descend through the directory structure, starting at the
%specified directory and collect information into a struct array with
%fields, path, m, mat, mex, mdl, p, classes, packages.  This is effectively
%a recursive version of the built in "what" command.

% This file is from pmtk3.googlecode.com


if nargin == 0
    directory = '.';
end

info = what(directory);
flist = dir(directory);
dlist =  {flist([flist.isdir]).name};
for i=1:numel(dlist)
    dirname = dlist{i};
    if(~strcmp(dirname,'.') && ~strcmp(dirname,'..'))
        info = [info, dirinfo([directory,'\',dirname])]; %#ok
    end
end

end
