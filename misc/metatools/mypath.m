function p = mypath()
% Return a list of all non-built-in directories on your matlab path
p = tokenize(path, ';'); 
p = p(~strncmp(matlabroot, p, length(matlabroot)));
p = filterCell(p, @(s)~isSubstring('.svn', s));
p = [p; pwd];
end