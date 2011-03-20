function ndx = strfindCell(str, cellarray)
% FInd occurrences of string in cellarray, or [] if absent
% Examples
% strfindCell('foo', {'foo', 'bar', 'foo'}) % [1 3]
% strfindCell('blah', {'foo', 'bar', 'foo'}) % []
 
% This file is from pmtk3.googlecode.com

ndx = find(cellfun(@(s) strcmpi(s, str), cellarray));


end
