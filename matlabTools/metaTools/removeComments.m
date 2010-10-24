function S = removeComments(S)
% Remove comments from a cell array storing mfile text. 
% The getText function returns the text of an mfile as a cell array, this
% function removes comments and blank lines from this cell array. 

% This file is from pmtk3.googlecode.com


blockCommentStart = cellfind(S, '%{');
blockCommentEnd   = cellfind(S, '%}');
ndx = [];
for i=1:numel(blockCommentStart)
   ndx = [ndx, blockCommentStart(i):blockCommentEnd(i)]; %#ok 
end
S(ndx) = [];


filter = @(str)~startswith(strtrim(str), '%') && ~isempty(strtrim(str));
S = filterCell(S, filter); 




end
