function str = htmlBreak(str)
% Convert new line chars to html breaks

% This file is from matlabtools.googlecode.com



str = regexprep(str, '\\n', '<br>');

end
