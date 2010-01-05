function results = globstrings(patterns, strs);
%GLOBSTRINGS  String matching via wildcards.
% GLOBSTRINGS(PATTERNS,STRINGS) returns a cell array of the strings from 
% STRINGS that match some wildcard pattern in PATTERNS.
% STRINGS is a cell array of strings.
% PATTERNS is a string or cell array of strings.
%
% Two types of wildcards are supported:
% * matches zero or more characters.
% ? matches exactly one character.
%
% Examples:
%   globstrings('f?*r',{'fr','fur','four'})   % returns {'fur','four'}
%   globstrings({'a*','*c'},{'ace','bar','rac'}) % returns {'ace','rac'}
%
% See also glob, glob2regexp.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

if ischar(patterns)
  patterns = cellstr(patterns)';
end
patterns = patterns;
results = {};
for i = 1:length(patterns)
  s = regexp(strs,glob2regexp(patterns{i}),'match');
  s = cat(2,s{:});
  if isempty(s)
    warning([patterns{i} ' did not match anything']);
  else
    results = {results{:} s{:}};
  end
end
