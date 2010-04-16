function n = countLinesOfCode(f)
% Count the number of lines of code in a function 
% excluding comments and empty spaces.

text = getText(f); 
text = cellfuncell(@(s)strtrim(s), text); 
text = filterCell(text, @(s)~isempty(s) && ~startswith(s, '%'));
n = numel(text); 


end