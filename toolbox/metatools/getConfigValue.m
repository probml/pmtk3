function value = getConfigValue(var)
%% Return the value of a configuration variable stored in config.txt
%
%% Example
% path = getConfigValue('PMTKsupportLink'); 

[tags, lines] = tagfinder(fullfile(pmtk3Root(), 'config.txt')); 
S = createStruct(tags, lines); 
value = S.(var); 
end