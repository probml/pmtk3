function answer = onMatlabPath(p)
% Return true if the specified path is currently on the Matlab search path.
%
% Example: 
%
%   onMatlabPath 'C:\pmtkData'
%
    answer = any(cellfun(@(s)strcmpi(s, p), tokenize(path(), ';')));
end