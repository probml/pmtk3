function value = getConfigValue(var)
%% Return the value of a configuration variable stored in config.txt
%
%% Example
% path = getConfigValue('PMTKsupportLink'); 

[tags, lines] = tagfinder(fullfile(pmtk3Root(), 'config.txt')); 
S = createStruct(tags, lines); 
if isfield(S, var)
    value = deblank(S.(var)); 
else
    value = '';
end
end