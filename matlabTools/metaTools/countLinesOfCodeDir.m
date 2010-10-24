function n = countLinesOfCodeDir(d, excludeComments, recursive, filemask)
% Count the total lines of code in all functions in a directory structure
% If recursive is true, (default) include subdirectories as well. 
% 

% This file is from pmtk3.googlecode.com


if nargin < 2, excludeComments = true; end
if nargin < 3, recursive = true; end
if nargin < 4, filemask = {'*.m', '*.c', '*.cpp', '*.h', '*.py'}; end

f = filelist(d, filemask, recursive);
counts = cellfun(@(c)countLinesOfCode(c, excludeComments), f); 
n = sum(counts); 


end
