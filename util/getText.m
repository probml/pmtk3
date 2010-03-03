function text = getText(textFile)
% Extract the text from a file. The output is a cell array - each cell is a line
% from the file. See also writeText()
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

while(true)
    tline = fgetl(fid);
    if ~ischar(tline), break; end
    text = [text; {tline}];
end

fclose(fid);
end