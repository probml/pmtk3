function n = countLinesOfCodeDir(d, recursive)
% Count the total number of lines of code in all of the functions in
% directory d. If recursive is true, (default) include subdirectories as
% well. 
% 

if nargin < 2, recursive = true; end
m = mfiles(d, 'topOnly', ~recursive); 
counts = cellfun(@countLinesOfCode, m); 
n = sum(counts); 


end