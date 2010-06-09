function fname = currentlyOpenFile(fullPath)
% Return the name of the file currently open in the editor. 
% If fullPath is true, (default = false), the full absolute path is 
% returned.
% PMTKneedsMatlab 


SetDefaultValue(1, 'fullPath', false); 
EDHANDLE = com.mathworks.mlservices.MLEditorServices;
fname = char(EDHANDLE.builtinGetActiveDocument);

if ~fullPath
    fname = argout(2, @fileparts, fname); 
end


end