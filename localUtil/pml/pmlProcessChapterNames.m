function chname = pmlProcessChapterNames(chname)
% Make sure the chapter names are valid directory names

% This file is from pmtk3.googlecode.com

chname = cellfuncell(@(c)regexprep(c, '[,()\[\]:;&%$#@!`?]', ''), chname);
chname = cellfuncell(@(c)strrep(strtrim(c), '  ', ' '), chname);
chname = cellfuncell(@(c)strrep(strtrim(c), 'unfinished', ''), chname);
chname = cellfuncell(@(c)strrep(strtrim(c), 'Unfinished', ''), chname);
chname = cellfuncell(@(c)strrep(strtrim(c), ' ', '_'), chname);
end
