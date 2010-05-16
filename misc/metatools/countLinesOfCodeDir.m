function n = countLinesOfCodeDir(d, excludeComments, recursive)
% Count the total number of lines of code in all of the functions in
% directory d. If recursive is true, (default) include subdirectories as
% well. 
% 

if nargin < 2, excludeComments = true; end
if nargin < 3, recursive = true; end

f = filelist(d, {'*.m', '*.c'}, recursive);
counts = cellfun(@(c)countLinesOfCode(c, excludeComments), f); 
n = sum(counts); 


end