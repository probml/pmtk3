function text = getText(textFile)
% Extract the text from a file. The output is a cell array - each cell is a line
% from the file. See also writeText()

% This file is from pmtk3.googlecode.com

text = {};
w = which(textFile);
if ~isempty(w)
    textFile = w;
end

fid = fopen(textFile);
if(fid < 0)
    fprintf('Sorry could not open %s\n',textFile);
    return;
end
alloc = cell(5000, 1);
text  = alloc;
i = 1;
while(true)
    tline = fgetl(fid);
    if ~ischar(tline)
        break;
    end
    text{i} = tline;
    i = i+1;
    if i > numel(text)
        text = [text; alloc]; %#ok
    end
end
text = text(1:i-1);
fclose(fid);
end
