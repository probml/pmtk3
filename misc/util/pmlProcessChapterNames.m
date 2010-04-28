function chname = pmlProcessChapterNames(chname)
% make sure the chapter names are valid directory names
chname = cellfuncell(@(c)regexprep(c, '[,()\[\]:;&%$#@!`?]', ''), chname);
chname = cellfuncell(@(c)strrep(strtrim(c), '  ', ' '), chname);
chname = cellfuncell(@(c)strrep(strtrim(c), 'unfinished', ''), chname);
chname = cellfuncell(@(c)strrep(strtrim(c), 'Unfinished', ''), chname);
chname = cellfuncell(@(c)strrep(strtrim(c), ' ', '_'), chname);
end