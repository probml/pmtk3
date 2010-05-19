function str = htmlBreak(str)
% Convert new line chars to html breaks


str = regexprep(str, '\\n', '<br>');

end