function n = countLinesOfCodeDir(d, excludeComments, recursive, filemask)
% Count the total number of lines of code in all of the functions in
% directory d. If recursive is true, (default) include subdirectories as
% well. 
% 

if nargin < 2, excludeComments = true; end
if nargin < 3, recursive = true; end
if nargin < 4, filemask = {'*.m', '*.c', '*.cpp', '*.h', '*.py'}; end

f = filelist(d, filemask, recursive);
counts = cellfun(@(c)countLinesOfCode(c, excludeComments), f); 
n = sum(counts); 


end