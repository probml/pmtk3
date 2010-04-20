function ndx = findname(pattern,string)
% It would be nice to write something like find(string == pattern ) to return the
% indices of the cells in string containing the pattern much like we write
% find(a == b) where a is say 1:10 and b is 3 to return the index 3.
% Unfortunately, Matlab does not allow this so use this function instead. 
%
% example
%
% a = {'foo','bar','yes','no','maybe'};
% ndx = findname('bar',a)
% ndx =
%      2

    ndx = find(cell2mat(cellfun(@(str)~isempty(str),strfind(string,pattern),'UniformOutput',false)));

end