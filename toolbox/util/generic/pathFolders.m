function d = pathFolders(p)
%% Return the folders in a file path

sep = ['\', filesep]; 
d = tokenize(fileparts(p), sep);

end
