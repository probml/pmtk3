function [X, y] = mlcompReadData(fpath)

raw = cell2mat(cellfun(@(s)tokenize(strrep(s, ':', ' ')), getText(fpath), 'UniformOutput', false));
raw(:, end) = [];
y = raw(:, 1); 
X = raw(:, 3:2:end); 

end

function toks = tokenize(s)
    if isempty(s)
        toks = [];
        return;
    end
    [tok, remaining] = strtok(s, ' '); 
    toks = [str2double(tok), tokenize(remaining)];
end