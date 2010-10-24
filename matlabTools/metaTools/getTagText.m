function str = getTagText(f, tag)
%% Return the text appearing after the tag in file f.
% If there is no such tag, an empty cell array is returned. 
% If f is a cell array of file names, repeat for each and return a cell
% array of strings.

% This file is from pmtk3.googlecode.com


if iscell(f)
    str = cellfuncell(@(ff)getTagText(ff, tag), f);
    return;
end

[tag, line] = tagfinder(f, {tag});
str = strtrim(line);

end
