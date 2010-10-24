function files = currentlyOpenFiles()
% Return a cell array of currently open files
% PMTKneedsMatlab 

% This file is from pmtk3.googlecode.com

E = com.mathworks.mlservices.MLEditorServices;
jdocs = E.builtinGetOpenDocumentNames();
ndocs = numel(jdocs);
files = cell(ndocs, 1); 
for i=1:ndocs
    files{i} = char(jdocs(i)); 
end
