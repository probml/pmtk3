function answer = isEndKeywordMissing(fname)
% Return true if the syntactically optional end keyword is missing 
% from the end of the function. 

% This file is from pmtk3.googlecode.com


if ~isfunction(fname)
    answer = false;
    return
end
text = removeComments(getText(fname)); 
text = cellfuncell(@removeStrings, text);
text = cellfuncell(@removeTrailingComment, text); 
answer = countEnds(text) ~= countKeywords(text); 

end

function n = countEnds(c)

rowCount = @(s)numel(intersect({'end'}, tokenize(strtrim(s), ' ;,')));
n = sum(cellfun(rowCount, c));
end

function n = countKeywords(c)

keywords = {'function', 'if', 'if~', 'switch', 'for', 'while', 'try'};
rowCount = @(s)numel(intersect(keywords, tokenize(strtrim(s), ' ;,=()')));
n = sum(cellfun(rowCount, c));

end

function s = removeTrailingComment(s)
    toks = tokenize(s, '%'); 
    s = toks{1};
end

function s = removeStrings(s)
    ndx = find(s=='''');
    j = 1;
    remove = [];
    while j < numel(ndx)
        remove = [remove, ndx(j):ndx(j+1)]; %#ok
        j = j+2;
    end
    s(remove) = '''';
end
