function n = countLinesOfCode(f, excludeComments)
% Count the number of lines of code in a function.
% If excludeComments is true, (default) then comments are excluded.

% This file is from pmtk3.googlecode.com


if nargin < 2, excludeComments = true; end

text = getText(f); 
text = cellfuncell(@(s)strtrim(s), text); 
text = filterCell(text, @(s)~isempty(s));
if excludeComments
   text = filterCell(text, @(s)~startswith(s, '%'));  
end
n = numel(text); 


end
