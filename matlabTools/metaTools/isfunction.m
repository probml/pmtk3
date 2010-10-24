function tf = isfunction(fname)
% Return true if the specified file is a matlab function, (not a script).
%

% This file is from pmtk3.googlecode.com


if endswith(fname, '.m')
    fname = fname(1:end-2);
end

w = which(fname); 
if startswith(w, 'built-in')
    tf = true;
    return;
end

if ~exist(fname, 'file')
    tf = false;
    return;
end

if isclassdef(fname)
    tf = false;
    return;
end

text = filterCell(getText(fname), @(s)~startswith(strtrim(s), '%'));
tf = any( cellfun(@(s)startswith(strtrim(s), 'function'), text));


end
