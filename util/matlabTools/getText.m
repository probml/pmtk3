function text = getText(textFile)
% Extract the text from a file. The output is a cell array - each cell is a line
% from the file. See also writeText()
    text = {};
    if(textFile(end) ~= 'm' && ~ismember('.',textFile))
       textFile = [textFile,'.m']; 
    end
    fid = fopen(textFile);
    if(fid < 0)
        fprintf('Sorry could not open %s\n',textFile);
        return;
    end
    text = textscan(fid,'%s','delimiter','\n','whitespace','');
    text = text{:};
    fclose(fid);
end