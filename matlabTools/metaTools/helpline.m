function [h, remaining] = helpline(f)
%% Return the first line of comments from a file.
% remaining is the remaining comment text

% This file is from pmtk3.googlecode.com

text = filterCell(cellfuncell(@strtrim, getText(f)), @(c)startswith(c, '%'));
text = removeEmpty(cellfuncell(@(c)strrep(c, '%', '') , text));

if isempty(text)
    h = '';
    remaining = '';
else
    h = strtrim(text{1});
    remaining = text(2:end);
end

end
