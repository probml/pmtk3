function pattern = glob2regexp(pattern)
%GLOB2REGEXP   Convert a glob pattern into a regexp pattern.
% GLOB2REGEXP(PATTERN) returns a regexp pattern which matches the same strings
% as the given glob pattern.
%
% Examples:
%   glob2regexp('my*file?.txt')
%   returns '^my.*file.\.txt$'

pattern = strrep(pattern,'.','\.');
pattern = strrep(pattern,'*','.*');
pattern = strrep(pattern,'?','.');
pattern = ['^' pattern '$'];
