function folders = dirPMTK(f)
% Return list of files in a directory/folder as a cell array
% We exclude '.' and '..' if present (on unix systems)
% We also exclude .svn
folders2 = dir(f);
folders = {folders2.name};
folders = setdiff(folders, '.');
folders = setdiff(folders, '..');
folders = setdiff(folders, '.svn');
end