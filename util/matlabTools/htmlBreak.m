function str = htmlBreak(str)
% convert new line chars to <br> for html    
    
    
    str = regexprep(str, '\\n', '<br>');
    
end