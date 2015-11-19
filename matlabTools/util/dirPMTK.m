function files = dirPMTK(f)
% Return list of files in a directory/folder as a cell array
% We exclude '.' and '..' if present (on unix systems)
% We also exclude .svn and .DS_Store
files2 = dir(f);
files2 = files2(~cellfun('isempty', {files2.date})); 
files = {files2.name};
files = setdiff(files, '.');
files = setdiff(files, '..');
files = setdiff(files, 'DS_Store');
files = setdiff(files, '.svn');
end