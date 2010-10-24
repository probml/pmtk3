function l = filelist(directory, filemask, recursive)
% Return a list of all files of the specified type in a directory structure
%  * .svn files and directories are ignored
%  * directories are not included in the list even for *.* - see dirs()
% 
%% Inputs [default]
% directory  [pwd()] the top level directory
% filemask   [*.*] is a windows style file specifier like '*.exe', '*.*',
%                  '*.txt', etc.  filemask can also by a cell array,
%                  in which case the union of the results from each mask
%                  are taken.
% recursive  [true] if true, the entire directory structure is searched,
%                   otherwise just the specified directory.
%% Output
%
% l                 a list of files with absolute path names.
%% Examples
% filelist(pmtk3Root(), '*.mex*') % returns all mex files in PMTK3
% filelist(pmtk3Root(), '*.exe') % returns all exe files in PMTK3
% filelist(pmtk3Root(), {'*.mex*', '*.exe'}) is the union of the above two calls
%
%%

% This file is from pmtk3.googlecode.com

SetDefaultValue(1, 'directory', pwd());
SetDefaultValue(2, 'filemask', '*.*');
SetDefaultValue(3, 'recursive', true);

if iscell(filemask)
    l = filelist(directory, filemask{1});
    for i=2:numel(filemask);
        l = union(l, filelist(directory, filemask{i}));
    end
    return;
end

if recursive
    l = filelistHelper(directory, filemask);
else
    cf = dir(fullfile(directory, filemask));
    l  = cellfuncell(@(f)fullfile(directory, f), {cf.name});
    l  = l(~[cf.isdir]);
end
l = filterCell(l, @(c)~endswith(c, '.') &&...
    ~endswith(c, '..') && ...
    ~endswith(c, '.svn'))';
l = unique(l);
l = l(sortidx(lower(l))); 
end


function [files, info] = filelistHelper(directory, ext, files)
% Recurisve accumulator
if(nargin < 1);
    directory = pwd();
end
if(nargin < 3)
    files = {};
end
if endswith(directory, '.svn')
    info = [];
    return
end
cf = dir(fullfile(directory, ext));
files = {cf.name};
files = cellfuncell(@(f)fullfile(directory, f), files);
files = files(~[cf.isdir]);
info = what(directory);
flist = dir(directory);
dlist =  {flist([flist.isdir]).name};
for i=1:numel(dlist)
    dirname = dlist{i};
    if(~strcmp(dirname,'.') && ~strcmp(dirname,'..'))
        [newfiles, newInfo] = filelistHelper(...
            fullfile(directory, dirname), ext, files);
        info = [info, newInfo];     %#ok<AGROW>
        files = [files, newfiles];  %#ok<AGROW>
    end
end
end
