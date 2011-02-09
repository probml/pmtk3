function p = mypath()
% Return a list of all non-built-in directories on your matlab path

% This file is from pmtk3.googlecode.com

if ispc
    p = tokenize(path, ';');
else
    p  = tokenize(path, ':');
end
p = p(~strncmp(matlabroot, p, length(matlabroot)));
p = filterCell(p, @(s)~isSubstring('.svn', s));
p = [p; pwd];
end
