function found = tagsearch(filename,tag)
% Checks to see if the specified tag is in the text of the specified file. 
%
% example
%
% found = tagsearch('LRvsSVM','%#exclude');
    
    text = getText(filename);
    f = @(str)strfind(str,tag);
    found = ~isempty(cell2mat(cellfun(f,text,'UniformOutput',false)));
    
end