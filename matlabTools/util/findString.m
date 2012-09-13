function idx = findString(str, cellArray,ignoreCase)
% Returns a boolean matrix the same size as cellArray with true everywhere
% the corresponding cell holds the specified string, str. 
    
   if nargin < 3, ignoreCase = false; end
   if ignoreCase, fn = @(c)strcmpi(c,str); else fn = @(c)strcmp(c,str); end
   idx = cellfun(fn,cellArray);
end
