function [X, y, comments] = mlcompReadData(fpath)
% Convert an mlcomp data file to matlab format. 

startswith = @(str, prefix)strncmp(str, prefix, length(prefix));
raw = getText(fpath);
iscomment = cellfun(@(s)startswith(strtrim(s), '#'), raw);
comments = raw(iscomment);
raw = raw(~iscomment);
parser = @(s)tokenize(strrep(strtrim(s), ':', ' '));
raw = cellfun(parser, raw, 'UniformOutput', false);
d = (max(cellfun(@numel, raw)) - 1)/2;
n = numel(raw);
X = zeros(n, d); 
y = zeros(n, 1);
for i=1:n
   row = raw{i};
   y(i) = row(1); 
   for j=2:2:numel(row)
       X(i, row(j)) = row(j+1);
   end
end

end

function toks = tokenize(s)
    if isempty(s)
        toks = [];
        return;
    end
    [tok, remaining] = strtok(s, ' ');
    toks = str2double(tok);
    while ~isempty(remaining)
        [tok, remaining] = strtok(remaining, ' '); %#ok  octave has no textscan function
        if ~isempty(tok)
            toks = [toks, str2double(tok)]; %#ok
        end
    end
    
end
