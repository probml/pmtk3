function tf = isfunction(fname)
% Return true if the specified file is a matlab function, (not a script).
%

w = which(fname); 
if startswith(w, 'built-in')
    tf = true;
    return;
end

if ~exist(fname, 'file')
    tf = false;
    return;
end


text = filterCell(getText(fname), @(s)~startswith(strtrim(s), '%'));
tf = any( cellfun(@(s)startswith(strtrim(s), 'function'), text));


end