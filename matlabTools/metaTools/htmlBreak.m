function str = htmlBreak(str)
% Convert new line chars to html breaks

% This file is from pmtk3.googlecode.com



str = regexprep(str, '\\n', '<br>');

end
