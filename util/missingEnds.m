function R = missingEnds()
% Return a list of all of the non-builtin mfiles on the matlab path that
% are missing the syntactically optional end keyword at the end of the 
% function. 

fileNames = filterCell(allMfilesOnPath(),@isfunction);
files = cellfuncell(@(m)removeComments(getText(m)), fileNames());

endCounts = cellfun(@(c)countEnds(c), files);
keyCounts = cellfun(@(c)countKeywords(c), files); 
R = fileNames(endCounts ~= keyCounts); 


end


function n = countEnds(c)

rowCount = @(s)numel(intersect({'end'}, tokenize(strtrim(s), ' ;,=()')));
n = sum(cellfun(rowCount, c)); 
end

function n = countKeywords(c)

keywords = {'function', 'if', 'switch', 'for', 'while', 'try', 'classdef'};
rowCount = @(s)numel(intersect(keywords, tokenize(strtrim(s), ' ;,=()')));
n = sum(cellfun(rowCount, c)); 

end