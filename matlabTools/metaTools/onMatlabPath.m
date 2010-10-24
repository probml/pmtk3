function answer = onMatlabPath(p, loose)
% Return true if the specified path is currently on the Matlab search path.
% If loose is true, (default = false), then answer is true if any
% subdirectory of p is on the path.
%
%% Example:
%
%   onMatlabPath 'C:\pmtkData'
%%

% This file is from pmtk3.googlecode.com

SetDefaultValue(2, 'loose', false);
if loose
    answer = any(cellfun(@(s)isSubstring(p, s), tokenize(path(), ';')));
else
    answer = any(cellfun(@(s)strcmpi(s, p), tokenize(path(), ';')));
end
end
