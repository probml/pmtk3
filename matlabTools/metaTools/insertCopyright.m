function insertCopyright(noticeText, file, verbose)
%% Insert a copyright notice into the specified file
% noticeText is a single string, or cell array of strings, one cell per
% line and is written as a comment to the specified file - the %
% prefixes are automatically added. It is inserted immediately after the
% first contiguous comment block, and automatically includes one blank,
% (comment free) line, before and after. If a file already
% has exactly the same comment notice, it is not written twice.
%%

% This file is from pmtk3.googlecode.com

if nargin < 3, verbose = true; end
if iscell(noticeText)
    noticeText = [{''}; {'%% '}; noticeText; {'%%'}; {''}];
else
    noticeText = [{''}; {noticeText}; {''}];
end
for i=1:numel(noticeText)
    t = noticeText{i};
    if ~isempty(t) && ~startswith(strtrim(t), '%')
        t = ['% ', t];
    end
    noticeText{i} = t;
end

f   = which(file);
src = getText(f);
if isempty(f) && verbose
    fprintf('could not find or read %s\n', file);
end

if isSubstring(catString(noticeText, ' '), catString(src, ' '))
    if verbose
        fprintf('%s already contains this notice\n', file);
    end
else
    commentNdx = cellfun(@(c)startswith(strtrim(c), '%'), src);
    loc = find(diff(commentNdx) == -1, 1, 'first');
    if isempty(loc), loc = 0; end
    src = [src(1:loc); noticeText; src(loc+1:end)];
    writeText(src, f);
end
end
