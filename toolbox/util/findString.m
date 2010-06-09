function idx = findString(str, cellArray, ignoreCase)
% Return a binary mask indicating where a string occurs in a cell array

if nargin < 3, ignoreCase = false; end
if ignoreCase, fn = @(c)strcmpi(c,str); else fn = @(c)strcmp(c,str); end
idx = cellfun(fn,cellArray);
end