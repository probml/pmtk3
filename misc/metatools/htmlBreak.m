function str = htmlBreak(str)
% Convert new line chars to <br> for html


str = regexprep(str, '\\n', '<br>');

end