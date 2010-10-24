function d = pathFolders(p)
%% Return the folders in a file path

% This file is from pmtk3.googlecode.com


sep = ['\', filesep]; 
d = tokenize(fileparts(p), sep);

end
