function s = safeStr(s)
% Change punctuation characters to they print properly

% This file is from matlabtools.googlecode.com


s = strrep(s, '\', '/');
s = strrep(s, '_', '-');

end
