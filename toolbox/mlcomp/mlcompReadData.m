function [X, y] = mlcompReadData(fpath)
% Convert an mlcomp data file to matlab format. 

parser = @(s)tokenize(strrep(strtrim(s), ':', ' '));
raw = cellfun(parser, getText(fpath), 'UniformOutput', false);
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
    toks = [str2double(tok), tokenize(remaining)];
end