function R = missingEnds()
% Find all non-builtin matlab files missing a final "end" statement
%
% Return a list of all of the non-builtin mfiles on the matlab path that
% are missing the syntactically optional end keyword at the end of the 
% function. 

% This file is from pmtk3.googlecode.com

fileNames = allMfilesOnPath();
ndx = cellfun(@isEndKeywordMissing, fileNames); 
R = fileNames(ndx); 
end

